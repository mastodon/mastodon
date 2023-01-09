import { RemovalPolicy, Stack, StackProps, Duration, CfnOutput } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Repository } from 'aws-cdk-lib/aws-ecr'
import { RetentionDays, LogGroup} from 'aws-cdk-lib/aws-logs';
import { FargateTaskDefinition, AwsLogDriverMode, ContainerDefinitionOptions } from 'aws-cdk-lib/aws-ecs'
import { Cluster, ContainerImage, LogDrivers, Secret} from 'aws-cdk-lib/aws-ecs' 
import { HostedZone } from 'aws-cdk-lib/aws-route53'
import { ApplicationMultipleTargetGroupsFargateService }  from 'aws-cdk-lib/aws-ecs-patterns'
import { CertificateValidation, DnsValidatedCertificate } from 'aws-cdk-lib/aws-certificatemanager';
import { ApplicationProtocol, SslPolicy } from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import { Protocol, Vpc } from 'aws-cdk-lib/aws-ec2'
import { EcsApplication } from 'aws-cdk-lib/aws-codedeploy';

import * as origins from "aws-cdk-lib/aws-cloudfront-origins";
import * as cf from "aws-cdk-lib/aws-cloudfront";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as route53Targets from "aws-cdk-lib/aws-route53-targets";
import * as rds from 'aws-cdk-lib/aws-rds';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as elb from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as elasticache from 'aws-cdk-lib/aws-elasticache';
import * as ses from 'aws-cdk-lib/aws-ses';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import * as opensearch from 'aws-cdk-lib/aws-opensearchservice';




export interface MastodonProps extends StackProps {
  PRODUCTION: boolean,
  domain: string,
  secrets: {
    SMTP_LOGIN: string,
    SMTP_PASSWORD: string,
    OTP_SECRET: string,
    SECRET_KEY_BASE: string,
    VAPID_PRIVATE_KEY: string,
    VAPID_PUBLIC_KEY: string,
  },
  FIRST_RUN: boolean,
}

export class MastodonStack extends Stack {
  constructor(scope: Construct, id: string, props: MastodonProps) {
    super(scope, id, props);

    const repository = Repository.fromRepositoryName(this, 'repo', 'hello-mastodon')

    // VPC
    const vpc = new Vpc(this, "vpc", {
      maxAzs: 2,
      vpcName: 'mastodon'
    })

    // Opensearch
    const osDomain = new opensearch.Domain(this, 'Domain', {
      version: opensearch.EngineVersion.OPENSEARCH_1_3,
      vpc,
      vpcSubnets: [{
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS, availabilityZones: [Stack.of(this).availabilityZones[0]]}], // Provision to the first private subnet only
      capacity: {
        masterNodes: 0,
        dataNodes: 1,
        dataNodeInstanceType: "t3.small.search",
      },
      ebs: {
        volumeSize: 10,
      },
      logging: {
        slowSearchLogEnabled: true,
        appLogEnabled: true,
        slowIndexLogEnabled: true,
      },
      encryptionAtRest: {
        enabled: true,
      },
      fineGrainedAccessControl: {
        masterUserName: 'mastodon',
      },
      nodeToNodeEncryption: true,
      enforceHttps: true,
    });

    const osSecret = new secretsmanager.Secret(this, 'osSecret', {
      secretStringValue: osDomain.masterUserPassword,
  });


    // Route 53
    const zone = HostedZone.fromLookup(this,'zone',{domainName: props.domain})


    // CW Log group
    const logGroup = new LogGroup(this, 'webLog', {
      logGroupName: 'web',
      retention: (props.PRODUCTION) ? RetentionDays.ONE_MONTH : RetentionDays.ONE_WEEK,
      removalPolicy: (props.PRODUCTION) ? RemovalPolicy.RETAIN : RemovalPolicy.DESTROY
    })

    // CloudFront 

    const requestPolicyAPI = new cf.OriginRequestPolicy( this, 'API', {
      cookieBehavior: cf.OriginRequestCookieBehavior.all(),
      queryStringBehavior: cf.OriginRequestCookieBehavior.all(),
      headerBehavior: cf.OriginRequestHeaderBehavior.all()
    });

    const webCertificate = new DnsValidatedCertificate(this,'certWeb',{
      domainName: props.domain,
      validation: CertificateValidation.fromDns(zone),
      hostedZone: zone,
      region: 'us-east-1'
    })

    // proxy analytics
    const plausible = new origins.HttpOrigin('plausible.io',{
      protocolPolicy: cf.OriginProtocolPolicy.HTTPS_ONLY
    })

    const albHost = 'alb.' + props.domain

    const albOrigin = new origins.HttpOrigin(albHost) //LoadBalancerV2Origin(props.alb)

    const params:cf.DistributionProps = {
      domainNames: [props.domain],
      priceClass: cf.PriceClass.PRICE_CLASS_100,
      certificate: webCertificate,
      logFilePrefix: props.domain,
      httpVersion: cf.HttpVersion.HTTP2_AND_3,
      defaultBehavior: {
        origin: albOrigin,
        allowedMethods: cf.AllowedMethods.ALLOW_ALL,
        cachePolicy: (props.PRODUCTION) ? cf.CachePolicy.CACHING_OPTIMIZED : cf.CachePolicy.CACHING_DISABLED,
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

    // RDS Postgres Instance

    const dbInstance = new rds.DatabaseInstance(this, 'db-instance', {
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
      },
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_13,
      }),
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.BURSTABLE3,
        ec2.InstanceSize.MICRO,
      ),
      credentials: rds.Credentials.fromGeneratedSecret('postgres'),
      multiAz: false,
      allocatedStorage: 25,
      allowMajorVersionUpgrade: false,
      autoMinorVersionUpgrade: true,
      backupRetention: (props.PRODUCTION) ? Duration.days(7) : Duration.days(0),
      deleteAutomatedBackups: (props.PRODUCTION) ? false : true,
      removalPolicy: (props.PRODUCTION) ? RemovalPolicy.RETAIN : RemovalPolicy.DESTROY,
      deletionProtection: false,
      databaseName: 'MastodonDB',
      publiclyAccessible: false,
    });

    const dbRecord = new route53.CnameRecord(this, 'dbRecord', {
      recordName: 'mastodondb',
      zone: zone,
      domainName: dbInstance.instanceEndpoint.hostname
    })


    // ElastiCache Redis instance
    const redisSubnetGroup = new elasticache.CfnSubnetGroup(this, 'redis-subnet-group', {
      cacheSubnetGroupName: 'redis-subnet-group',
      description: 'The redis subnet group id',
      subnetIds: vpc.privateSubnets.map(subnet => subnet.subnetId)
    });
  
    const redisSecurityGroup = new ec2.SecurityGroup(this, 'redis-security-group', { vpc: vpc });
  
    const redisConnections = new ec2.Connections({
        securityGroups: [redisSecurityGroup],
        defaultPort: ec2.Port.tcp(6379)
    });
  
    const redis = new elasticache.CfnCacheCluster(this, 'redis-cluster', {
        cacheNodeType:'cache.t4g.micro',
        engine: 'redis',
        engineVersion: '7.0',
        numCacheNodes: 1,
        port: 6379,
        cacheSubnetGroupName: redisSubnetGroup.cacheSubnetGroupName,
        vpcSecurityGroupIds: [ redisSecurityGroup.securityGroupId ]
    });
    redis.addDependency(redisSubnetGroup);
  
    const redisRecord = new route53.CnameRecord(this, 'redisRecord', {
      recordName: 'mastodonredis',
      zone: zone,
      domainName: redis.attrRedisEndpointAddress
    })

    // S3
    const bucketName = 'mastodon-'+props.domain.replace('.','-') // Kyle: I have found S3 is cranky with dots in the bucket name -- I replace dots with dashes
    const bucket = new s3.Bucket(this, bucketName, { 
      bucketName: bucketName,
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: {blockPublicAcls: false, blockPublicPolicy: false, ignorePublicAcls: false, restrictPublicBuckets: false},
    });

    // IAM user for S3 bucket
    const user = new iam.User(this, 'mastodon-s3-user');
    const accessKey = new iam.AccessKey(this, 'AccessKey', { user });
    const iamSecret = new secretsmanager.Secret(this, 'Secret', {
        secretStringValue: accessKey.secretAccessKey,
    });

    const bucketPolicy = new iam.PolicyStatement({
      actions: ['s3:*'],
      resources: [
        bucket.arnForObjects('*'),
        bucket.bucketArn
      ],
      principals: [new iam.ArnPrincipal(user.userArn)]
    });

    bucket.addToResourcePolicy(bucketPolicy);

    user.attachInlinePolicy(new iam.Policy(this, 'mastodon-s3-policy', {
      statements: [new iam.PolicyStatement({
        resources: [
          bucket.bucketArn,
          bucket.bucketArn + '/*'
        ],
        actions: ['s3:*'],
        effect: iam.Effect.ALLOW,
      })],
    }));


    // ECS Fargate Task
    const mastodonTask = new FargateTaskDefinition( this, 'mastodonTask', {
      cpu: 1024,
      family: 'mastodon',
      memoryLimitMiB: 2048
    })

    // ECS ALB
    const albCertificate = new DnsValidatedCertificate(this,'certALB',{
      domainName: albHost,
      validation: CertificateValidation.fromDns(zone),
      hostedZone: zone,
    })

    // Mastodon tasks
    const dbSecret = secretsmanager.Secret.fromSecretCompleteArn(this, "dbSecret", dbInstance.secret?.secretArn!);


// TODO - switch to using
//   environmentFiles: [ ecs.EnvironmentFile.fromAsset('./xxx.env') https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_ecs.EnvironmentFile.html

    const  environment = {
      AWS_ACCESS_KEY_ID: accessKey.accessKeyId,
      REDIS_HOST: redisRecord.domainName,
      DB_HOST: dbRecord.domainName,
      S3_BUCKET: bucket.bucketName,
      LOCAL_DOMAIN: props.domain,
      ES_ENABLED: 'true',
      ES_HOST: osDomain.domainEndpoint,
      ES_PORT: '443',
      ES_USER: "mastodon",
      SMTP_FROM_ADDRESS: 'Mastodon <notifications@' + props.domain + '>',
      // passed in secrets
      SMTP_LOGIN:         props.secrets.SMTP_LOGIN,
      SMTP_PASSWORD:      props.secrets.SMTP_PASSWORD,
      OTP_SECRET:         props.secrets.OTP_SECRET,
      SECRET_KEY_BASE:    props.secrets.SECRET_KEY_BASE,
      VAPID_PRIVATE_KEY:  props.secrets.VAPID_PRIVATE_KEY,
      VAPID_PUBLIC_KEY:   props.secrets.VAPID_PUBLIC_KEY,
      // TBD - move to .env file
      DB_USER:'postgres',
      REDIS_PORT:'6379',
      REDIS_PASSWORD:'',
      S3_ENABLED:'true',
      S3_PROTOCOL:'https',
      S3_REGION:'us-west-2',
      S3_HOSTNAME:'s3.us-west-2.amazonaws.com',
      SMTP_SERVER:'email-smtp.us-west-2.amazonaws.com',
      SMTP_PORT:'587',
      SMTP_AUTH_METHOD:'plain',
      SMTP_OPENSSL_VERIFY_MODE:'none',
      SMTP_ENABLE_STARTTLS:'auto',
      RAILS_LOG_TO_STDOUT:'enabled',
    }

    const secrets = {
      DB_PASS: Secret.fromSecretsManager(dbSecret, 'password'), 
      AWS_SECRET_ACCESS_KEY: Secret.fromSecretsManager(iamSecret),
      ES_PASS: Secret.fromSecretsManager(osSecret),
    }

    mastodonTask.addContainer('sidekiqContainer',{
      image: ContainerImage.fromEcrRepository(repository,'latest'),
      //image: ContainerImage.fromRegistry('tootsuite/mastodon'),
      containerName: 'sidekiq',
      command: ['bash', '-c', 'bundle exec sidekiq -c 15'],
      essential: false,
      logging: LogDrivers.awsLogs({
        streamPrefix: 'sidekiq',
        logGroup: logGroup
      }),
      environment,
      secrets
    })

    mastodonTask.addContainer('streamingContainer',{
      image: ContainerImage.fromEcrRepository(repository,'latest'),
      //image: ContainerImage.fromRegistry('tootsuite/mastodon'),
      containerName: 'streaming',
      command: ['bash', '-c', 'node ./streaming'],
      logging: LogDrivers.awsLogs({
        streamPrefix: 'streaming',
        logGroup: logGroup
      }),
      environment,
      secrets,
      portMappings: [{containerPort: 4000}]
    })

    mastodonTask.addContainer('webContainer',{
      image: ContainerImage.fromEcrRepository(repository,'latest'),
      //image: ContainerImage.fromRegistry('tootsuite/mastodon'),
      containerName: 'webserver',
      command: (props.FIRST_RUN) ? ['bash', '-c', 'bundle install && DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:setup && bundle exec rails db:migrate && bundle exec rails s -p 3000'] : ['bash', '-c', 'bundle install && bundle exec rails db:migrate && bundle exec rails s -p 3000'],
      logging: LogDrivers.awsLogs({
        streamPrefix: 'web',
        logGroup: logGroup
      }),
      environment,
      secrets,
      portMappings: [{containerPort: 3000}]
    })

    // ECS Cluster
    const ecsCluster = new ecs.Cluster(this, 'FargateCluster', {
      vpc,
      clusterName: "mastodon",
      containerInsights: true
    });

    // ECS Service
    const ecsService = new ecs.FargateService(this, 'Service', { 
      cluster: ecsCluster, 
      taskDefinition: mastodonTask,
      enableExecuteCommand: true
    })

    const scalableTarget = ecsService.autoScaleTaskCount({
      minCapacity: 1,
      maxCapacity: 20,
    })
    
    scalableTarget.scaleOnCpuUtilization('CpuScaling', {
      targetUtilizationPercent: 75,
    })
    
    scalableTarget.scaleOnMemoryUtilization('MemoryScaling', {
      targetUtilizationPercent: 80,
    })    

    // ALB
    const lb = new elb.ApplicationLoadBalancer(this, 'LB', {
      vpc,
      internetFacing: true
    });

    lb.setAttribute('routing.http.preserve_host_header.enabled', 'true')
    lb.setAttribute('routing.http.xff_client_port.enabled', 'true')
    lb.setAttribute('routing.http.xff_header_processing.mode', 'preserve')

    const albRecord = new route53.CnameRecord(this, 'albRecord', {
      recordName: 'alb',
      zone: zone,
      domainName: lb.loadBalancerDnsName
    })

    // Redirect HTTP to HTTPS
    lb.addRedirect({
      sourceProtocol: elb.ApplicationProtocol.HTTP,
      sourcePort: 80,
      targetProtocol: elb.ApplicationProtocol.HTTPS,
      targetPort: 443,
    })

    // HTTPS Listener
    const listener443 = lb.addListener('listener443', {
      port: 443,
      open: true,
      protocol: elb.ApplicationProtocol.HTTPS,
      certificates: [albCertificate],
      sslPolicy: SslPolicy.TLS12_EXT,
      defaultAction: elb.ListenerAction.fixedResponse(200, {
        messageBody: 'OK',
      })
    });

    ecsService.registerLoadBalancerTargets(
      {
        containerName: 'webserver',
        containerPort: 3000,
        newTargetGroupId: 'webserver',
        listener: ecs.ListenerConfig.applicationListener(listener443, {
          protocol: elb.ApplicationProtocol.HTTP,
          healthCheck: {path:"/health", interval: Duration.seconds(30), healthyThresholdCount: 3, unhealthyThresholdCount: 3},
          priority: 200,
          conditions: [
            elb.ListenerCondition.pathPatterns(['/*']),
          ]
        }),
      },
    );

    ecsService.registerLoadBalancerTargets(
      {
        containerName: 'streaming',
        containerPort: 4000,
        newTargetGroupId: 'streaming',
        listener: ecs.ListenerConfig.applicationListener(listener443, {
          protocol: elb.ApplicationProtocol.HTTP,
          healthCheck: {path:"/api/v1/streaming/health", interval: Duration.seconds(30), healthyThresholdCount: 3, unhealthyThresholdCount: 3},
          priority: 100,
          conditions: [
            elb.ListenerCondition.pathPatterns(['/api/v1/streaming','/api/v1/streaming/*']),
          ]
        }),
      },
    );
    
    const albSecurityGroup = new ec2.SecurityGroup(this, 'alb-security-group', { 
      vpc: vpc,
      allowAllOutbound: true,
     });
     
    lb.addSecurityGroup(albSecurityGroup)

    // Outputs
    new CfnOutput(this, 'dbEndpoint', {
      value: dbInstance.instanceEndpoint.hostname,
    });

    new CfnOutput(this, 'secretName', {
      value: dbInstance.secret?.secretName!,
    });

    redisConnections.connections.allowFrom(ecsService.connections, ec2.Port.tcp(6379));
    dbInstance.connections.allowFrom(ecsService.connections, ec2.Port.tcp(5432));
    osDomain.connections.allowFrom(ecsService.connections, ec2.Port.tcp(443));
  } 
}
