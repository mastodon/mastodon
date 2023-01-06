import { Stack, StackProps, Duration } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iam from 'aws-cdk-lib/aws-iam';


export interface OIDCProps extends StackProps {
  githubDomain: string,
  repositoryConfig: { owner: string; repo: string; filter?: string }[]
}

export class OIDCStack extends Stack {
  constructor(scope: Construct, id: string, props: OIDCProps) {
    super(scope, id, props);

    const oidc_provider = new iam.OpenIdConnectProvider(this, 'oidc-provider', {
      url: 'https://token.actions.githubusercontent.com',
      clientIds: [ 'sts.amazonaws.com' ],
    });

    const iamRepoDeployAccess = props.repositoryConfig.map(
      (r) => `repo:${r.owner}/${r.repo}:${r.filter ?? '*'}`
    );

    const conditions: iam.Conditions = {
      StringLike: {
        [`${props.githubDomain}:sub`]: iamRepoDeployAccess,
      },
    };

    const oidc_role = new iam.Role(this, 'oidc-role', {
      assumedBy: new iam.WebIdentityPrincipal(
        oidc_provider.openIdConnectProviderArn,
        conditions
      ),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('AdministratorAccess'),
      ],
      roleName: 'oidc-role',
      maxSessionDuration: Duration.hours(1),
    });

  } 
}
