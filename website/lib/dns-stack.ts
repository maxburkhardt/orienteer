import { CfnOutput, Fn, RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import * as route53 from "aws-cdk-lib/aws-route53";
import { Construct } from "constructs";

export interface DnsStackProps extends StackProps {
  domainName: string;
}

/**
 * The Route 53 zone for the site's domain. Kept in its own stack because the
 * registrar (Porkbun) must be pointed at these nameservers before the site
 * stack's certificate can validate.
 */
export class DnsStack extends Stack {
  readonly zone: route53.IHostedZone;

  constructor(scope: Construct, id: string, props: DnsStackProps) {
    super(scope, id, props);

    const zone = new route53.PublicHostedZone(this, "Zone", {
      zoneName: props.domainName,
    });
    // Deleting the zone would break delegation at the registrar, so keep it
    // even if the stack is torn down.
    zone.applyRemovalPolicy(RemovalPolicy.RETAIN);
    this.zone = zone;

    new CfnOutput(this, "NameServers", {
      description: "Set these as the domain's nameservers at the registrar",
      value: Fn.join(" ", zone.hostedZoneNameServers!),
    });
  }
}
