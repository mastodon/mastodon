import { RemovalPolicy, Stack, StackProps, Duration } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Repository } from 'aws-cdk-lib/aws-ecr'
import { RetentionDays, LogGroup} from 'aws-cdk-lib/aws-logs';
import { FargateTaskDefinition, AwsLogDriverMode } from 'aws-cdk-lib/aws-ecs'
import { Cluster, ContainerImage, LogDrivers} from 'aws-cdk-lib/aws-ecs' 
import { HostedZone } from 'aws-cdk-lib/aws-route53'
import { ApplicationLoadBalancedFargateService }  from 'aws-cdk-lib/aws-ecs-patterns'
import { CertificateValidation, DnsValidatedCertificate } from 'aws-cdk-lib/aws-certificatemanager';
import { Vpc } from 'aws-cdk-lib/aws-ec2'

import * as origins from "aws-cdk-lib/aws-cloudfront-origins";
import * as cf from "aws-cdk-lib/aws-cloudfront";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as route53Targets from "aws-cdk-lib/aws-route53-targets";


export interface MastodonProps extends StackProps {
  PRODUCTION: boolean,
  domain: string,
}

export class MastodonStack extends Stack {
  constructor(scope: Construct, id: string, props: MastodonProps) {
    super(scope, id, props);

    const repository = Repository.fromRepositoryName(this, 'repo', 'hello-mastodon')

    const logGroup = new LogGroup(this, 'webLog', {
      logGroupName: 'web',
      retention: (props.PRODUCTION) ? RetentionDays.ONE_MONTH : RetentionDays.ONE_WEEK,
      removalPolicy: RemovalPolicy.SNAPSHOT
    })


    const webTask = new FargateTaskDefinition( this, 'webTask', {
      cpu: 256,           // TODO 
      family: 'web',
      memoryLimitMiB: 512 // TODO
    })

    webTask.addContainer('webContainer',{
      image: ContainerImage.fromEcrRepository(repository,'latest'),
      containerName: 'web',

      // TODO replace with appropriate values
      // environment: {
      //   PORT: '7000',
      //   HELLO_DOMAIN: props.domain,
      //   NODE_ENV: props.PRODUCTION ? 'production' : 'staging',
      // },
      // healthCheck: {
      //   command: [
      //     'CMD-SHELL',
      //     'wget -q -O - http://localhost:7000/api/v1/health_check/local'
      //   ],
      //   interval: Duration.seconds(5),
      //   timeout: Duration.seconds(2),
      //   retries: 4,
      //   startPeriod: Duration.seconds(10)
      // },
      logging: LogDrivers.awsLogs({
        streamPrefix: 'web',
        mode: AwsLogDriverMode.NON_BLOCKING,
        logGroup: logGroup
      }),
      portMappings: [{containerPort:7000}], // TODO for port
    })

    const vpc = new Vpc(this, "vpc", {
      maxAzs: 2,
      vpcName: 'mastodon'
    })
    const cluster = new Cluster(this, 'mastodonCluster', { 
      vpc,
      clusterName: 'mastodon',
      containerInsights: true
    })

    const zone = HostedZone.fromLookup(this,'zone',{domainName: props.domain})

    const albHost = 'alb.'+props.domain

    const albCertificate = new DnsValidatedCertificate(this,'certALB',{
      domainName: albHost,
      validation: CertificateValidation.fromDns(zone),
      hostedZone: zone,
    })

    const loadBalancedFargateService = new ApplicationLoadBalancedFargateService(this, 'webFargate', {
      circuitBreaker: { rollback: true },
      cluster : cluster,
      cpu: 512,
      desiredCount: 1,
      domainName: albHost,
      domainZone: zone,
      certificate: albCertificate,
      loadBalancerName: 'mastodon',
      memoryLimitMiB: 1024,
      serviceName: 'mastodon',
      taskDefinition: webTask,
    });
    
    loadBalancedFargateService.targetGroup.configureHealthCheck({
      path: '/api/v1/health_check/ALB', // TODO
    })

    const scalableTarget = loadBalancedFargateService.service.autoScaleTaskCount({
      minCapacity: 1,
      maxCapacity: 20,
    })
    
    scalableTarget.scaleOnCpuUtilization('CpuScaling', {
      targetUtilizationPercent: 50,
    })
    
    scalableTarget.scaleOnMemoryUtilization('MemoryScaling', {
      targetUtilizationPercent: 50,
    })    

    //
    // TODO - grant permissions for webTask.taskRole to access all storage
    //

    // CloudFront setup

    const alb = loadBalancedFargateService.loadBalancer

    const albOrigin = new origins.HttpOrigin(albHost) //LoadBalancerV2Origin(props.alb)

    const requestPolicyAPI = new cf.OriginRequestPolicy( this, 'API', {
      cookieBehavior: cf.OriginRequestCookieBehavior.all(),
      queryStringBehavior: cf.OriginRequestCookieBehavior.all(),
      headerBehavior: cf.OriginRequestHeaderBehavior.allowList(
        'CloudFront-Viewer-Time-Zone',
        'CloudFront-Viewer-Country',
        'CloudFront-Viewer-Latitude',
        'CloudFront-Viewer-Longitude',
        'CloudFront-Viewer-City',
        'CloudFront-Viewer-Country-Region',
        'CloudFront-Viewer-Address',
        'Accept-Language',
      )
    });

    const webCertificate = new DnsValidatedCertificate(this,'certWeb',{
      domainName: props.domain,
      validation: CertificateValidation.fromDns(zone),
      hostedZone: zone,
    })

    // proxy analytics
    const plausible = new origins.HttpOrigin('plausible.io',{
      protocolPolicy: cf.OriginProtocolPolicy.HTTPS_ONLY
    })

    const params:cf.DistributionProps = {
      // defaultRootObject: 'index.html', // TODO
      domainNames: [props.domain],
      priceClass: cf.PriceClass.PRICE_CLASS_100,
      certificate: webCertificate,
      logFilePrefix: props.domain,
      defaultBehavior: {  // TODO - guessing default origin should be an S3 bucket that we have static content in?
        origin: albOrigin,
        allowedMethods: cf.AllowedMethods.ALLOW_ALL,
        cachePolicy: cf.CachePolicy.CACHING_DISABLED,
        originRequestPolicy: requestPolicyAPI,
        viewerProtocolPolicy: cf.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
      additionalBehaviors: {
        // analytics endpoints
        '/js/script*': {
          origin: plausible,
          allowedMethods: cf.AllowedMethods.ALLOW_GET_HEAD,
          viewerProtocolPolicy: cf.ViewerProtocolPolicy.HTTPS_ONLY,
        },
        '/api/event': {
          origin: (props.PRODUCTION) ? plausible : albOrigin,
          allowedMethods: cf.AllowedMethods.ALLOW_ALL,
          viewerProtocolPolicy: cf.ViewerProtocolPolicy.HTTPS_ONLY,
          originRequestPolicy: cf.OriginRequestPolicy.USER_AGENT_REFERER_HEADERS
        },
      }
    }

    const distribution = new cf.Distribution(this, 'distribution', params);

    new route53.ARecord(this, 'webRecord', {
      zone: zone,
      target: route53.RecordTarget.fromAlias(
        new route53Targets.CloudFrontTarget(distribution)
      )
    })
  }
}
