# orienteer.quest website

Static site in `public/` (landing page, 404 page and the App Clip's
`.well-known/apple-app-site-association`), hosted on S3 + CloudFront via AWS CDK.
Uses the `forge` AWS profile and deploys to us-east-1.

```sh
npm install
npm run deploy:dns   # Route 53 zone; prints the nameservers to set at the registrar
npm run deploy       # bucket, certificate, CloudFront, DNS records, uploads public/
```

Deploy the DNS stack once and point the domain's nameservers at it before the
first site deploy: the certificate validates through that zone, so the site
deploy waits until delegation is live. Afterwards, `npm run deploy` uploads any
changes in `public/` and invalidates the CloudFront cache.

Check the association file (must be 200 with `content-type: application/json`):

```sh
curl -i https://orienteer.quest/.well-known/apple-app-site-association
curl https://app-site-association.cdn-apple.com/a/v1/orienteer.quest  # Apple's cached copy
```
