import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { HostedZone } from 'aws-cdk-lib/aws-route53'
import * as ses from 'aws-cdk-lib/aws-ses';


export interface MailProps extends StackProps {
  domain: string,
}

export class MailStack extends Stack {
  constructor(scope: Construct, id: string, props: MailProps) {
    super(scope, id, props);

    // Route 53
    const zone = HostedZone.fromLookup(this,'zone',{domainName: props.domain})

    // SES
    const mailFromDomain = 'mail.'+props.domain
    const identity = new ses.EmailIdentity(this, 'Identity', {
      identity: ses.Identity.publicHostedZone(zone),
      mailFromDomain,
    });

  } 
}
