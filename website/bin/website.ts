import { App } from "aws-cdk-lib";
import { DnsStack } from "../lib/dns-stack.ts";
import { SiteStack } from "../lib/site-stack.ts";

const domainName = "orienteer.quest";

const app = new App();
// CloudFront certificates must live in us-east-1, so the whole site does too.
const env = { account: process.env.CDK_DEFAULT_ACCOUNT, region: "us-east-1" };

const dns = new DnsStack(app, "OrienteerDns", { env, domainName });

new SiteStack(app, "OrienteerSite", {
  env,
  zone: dns.zone,
  domainNames: [domainName, `appclip.${domainName}`],
});
