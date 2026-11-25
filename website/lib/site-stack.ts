import * as path from "node:path";
import { CfnOutput, Duration, RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import * as origins from "aws-cdk-lib/aws-cloudfront-origins";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as targets from "aws-cdk-lib/aws-route53-targets";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as s3deploy from "aws-cdk-lib/aws-s3-deployment";
import { Construct } from "constructs";

export interface SiteStackProps extends StackProps {
  zone: route53.IHostedZone;
  /** Every hostname the site answers on; the first is the certificate's primary name. */
  domainNames: string[];
}

const publicDir = path.join(import.meta.dirname, "..", "public");

/**
 * Static site on a private S3 bucket behind CloudFront. Serves the
 * apple-app-site-association file that backs the App Clip's associated domains.
 * Must be deployed in us-east-1, because CloudFront only accepts certificates from there.
 */
export class SiteStack extends Stack {
  constructor(scope: Construct, id: string, props: SiteStackProps) {
    super(scope, id, props);
    const [primaryName, ...otherNames] = props.domainNames;

    const bucket = new s3.Bucket(this, "Bucket", {
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      // Everything in the bucket is generated from public/ in git.
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    const certificate = new acm.Certificate(this, "Certificate", {
      domainName: primaryName,
      subjectAlternativeNames: otherNames,
      validation: acm.CertificateValidation.fromDns(props.zone),
    });

    const distribution = new cloudfront.Distribution(this, "Distribution", {
      domainNames: props.domainNames,
      certificate,
      defaultRootObject: "index.html",
      httpVersion: cloudfront.HttpVersion.HTTP2_AND_3,
      priceClass: cloudfront.PriceClass.PRICE_CLASS_100,
      defaultBehavior: {
        origin: origins.S3BucketOrigin.withOriginAccessControl(bucket),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
      },
      // A private bucket answers 403 for missing keys; show the 404 page for both.
      errorResponses: [403, 404].map((httpStatus) => ({
        httpStatus,
        responseHttpStatus: 404,
        responsePagePath: "/404.html",
        ttl: Duration.minutes(5),
      })),
    });

    // Site pages. The association file is excluded here (and so is also left
    // alone by this deployment's pruning) and uploaded separately below.
    new s3deploy.BucketDeployment(this, "DeploySite", {
      destinationBucket: bucket,
      sources: [s3deploy.Source.asset(publicDir, { exclude: [".well-known", ".well-known/**"] })],
      exclude: [".well-known/*"],
    });

    // The file has no extension, so S3 would label it binary/octet-stream.
    // Apple expects it to be served as JSON.
    new s3deploy.BucketDeployment(this, "DeployAppSiteAssociation", {
      destinationBucket: bucket,
      destinationKeyPrefix: ".well-known/",
      sources: [s3deploy.Source.asset(path.join(publicDir, ".well-known"))],
      contentType: "application/json",
      distribution,
      distributionPaths: ["/*"],
    });

    for (const name of props.domainNames) {
      const target = route53.RecordTarget.fromAlias(new targets.CloudFrontTarget(distribution));
      const recordName = name === props.zone.zoneName ? undefined : name;
      new route53.ARecord(this, `A-${name}`, { zone: props.zone, recordName, target });
      new route53.AaaaRecord(this, `AAAA-${name}`, { zone: props.zone, recordName, target });
    }

    new CfnOutput(this, "DistributionDomain", { value: distribution.distributionDomainName });
    new CfnOutput(this, "BucketName", { value: bucket.bucketName });
  }
}
