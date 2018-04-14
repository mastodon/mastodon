require_relative 'aws-partitions/endpoint_provider'
require_relative 'aws-partitions/partition'
require_relative 'aws-partitions/partition_list'
require_relative 'aws-partitions/region'
require_relative 'aws-partitions/service'

require 'json'

module Aws

  # A {Partition} is a group of AWS {Region} and {Service} objects. You
  # can use a partition to determine what services are available in a region,
  # or what regions a service is available in.
  #
  # ## Partitions
  #
  # **AWS accounts are scoped to a single partition**. You can get a partition
  # by name. Valid partition names include:
  #
  # * `"aws"` - Public AWS partition
  # * `"aws-cn"` - AWS China
  # * `"aws-us-gov"` - AWS GovCloud
  #
  # To get a partition by name:
  #
  #     aws = Aws::Partitions.partition('aws')
  #
  # You can also enumerate all partitions:
  #
  #     Aws::Partitions.each do |partition|
  #       puts partition.name
  #     end
  #
  # ## Regions
  #
  # A {Partition} is divided up into one or more regions. For example, the
  # "aws" partition contains, "us-east-1", "us-west-1", etc. You can get
  # a region by name. Calling {Partition#region} will return an instance
  # of {Region}.
  #
  #     region = Aws::Partitions.partition('aws').region('us-west-2')
  #     region.name
  #     #=> "us-west-2"
  #
  # You can also enumerate all regions within a partition:
  #
  #     Aws::Partitions.partition('aws').regions.each do |region|
  #       puts region.name
  #     end
  #
  # Each {Region} object has a name, description and a list of services
  # available to that region:
  #
  #     us_west_2 = Aws::Partitions.partition('aws').region('us-west-2')
  #
  #     us_west_2.name #=> "us-west-2"
  #     us_west_2.description #=> "US West (Oregon)"
  #     us_west_2.partition_name "aws"
  #     us_west_2.services #=> #<Set: {"APIGateway", "AutoScaling", ... }
  #
  # To know if a service is available within a region, you can call `#include?`
  # on the set of service names:
  #
  #     region.services.include?('DynamoDB') #=> true/false
  #
  # The service name should be the service's module name as used by
  # the AWS SDK for Ruby. To find the complete list of supported
  # service names, see {Partition#services}.
  #
  # Its also possible to enumerate every service for every region in
  # every partition.
  #
  #     Aws::Partitions.partitions.each do |partition|
  #       partition.regions.each do |region|
  #         region.services.each do |service_name|
  #           puts "#{partition.name} -> #{region.name} -> #{service_name}"
  #         end
  #       end
  #     end
  #
  # ## Services
  #
  # A {Partition} has a list of services available. You can get a
  # single {Service} by name:
  #
  #     Aws::Partitions.partition('aws').service('DynamoDB')
  #
  # You can also enumerate all services in a partition:
  #
  #     Aws::Partitions.partition('aws').services.each do |service|
  #       puts service.name
  #     end
  #
  # Each {Service} object has a name, and information about regions
  # that service is available in.
  #
  #     service.name #=> "DynamoDB"
  #     service.partition_name #=> "aws"
  #     service.regions #=> #<Set: {"us-east-1", "us-west-1", ... }
  #
  # Some services have multiple regions, and others have a single partition
  # wide region. For example, {Aws::IAM} has a single region in the "aws"
  # partition. The {Service#regionalized?} method indicates when this is
  # the case.
  #
  #     iam = Aws::Partitions.partition('aws').service('IAM')
  #
  #     iam.regionalized? #=> false
  #     service.partition_region #=> "aws-global"
  #
  # Its also possible to enumerate every region for every service in
  # every partition.
  #
  #     Aws::Partitions.partitions.each do |partition|
  #       partition.services.each do |service|
  #         service.regions.each do |region_name|
  #           puts "#{partition.name} -> #{region_name} -> #{service.name}"
  #         end
  #       end
  #     end
  #
  # ## Service Names
  #
  # {Service} names are those used by the the AWS SDK for Ruby. They
  # correspond to the service's module.
  #
  module Partitions

    class << self

      include Enumerable

      # @return [Enumerable<Partition>]
      def each(&block)
        default_partition_list.each(&block)
      end

      # Return the partition with the given name. A partition describes
      # the services and regions available in that partition.
      #
      #     aws = Aws::Partitions.partition('aws')
      #
      #     puts "Regions available in the aws partition:\n"
      #     aws.regions.each do |region|
      #       puts region.name
      #     end
      #
      #     puts "Services available in the aws partition:\n"
      #     aws.services.each do |services|
      #       puts services.name
      #     end
      #
      # @param [String] name The name of the partition to return.
      #   Valid names include "aws", "aws-cn", and "aws-us-gov".
      #
      # @return [Partition]
      #
      # @raise [ArgumentError] Raises an `ArgumentError` if a partition is
      #   not found with the given name. The error message contains a list
      #   of valid partition names.
      def partition(name)
        default_partition_list.partition(name)
      end

      # Returns an array with every partitions. A partition describes
      # the services and regions available in that partition.
      #
      #     Aws::Partitions.partitions.each do |partition|
      #
      #       puts "Regions available in #{partition.name}:\n"
      #       partition.regions.each do |region|
      #         puts region.name
      #       end
      #
      #       puts "Services available in #{partition.name}:\n"
      #       partition.services.each do |service|
      #         puts service.name
      #       end
      #     end
      #
      # @return [Enumerable<Partition>] Returns an enumerable of all
      #   known partitions.
      def partitions
        default_partition_list
      end

      # @param [Hash] new_partitions
      # @api private For internal use only.
      def add(new_partitions)
        new_partitions['partitions'].each do |partition|
          default_partition_list.add_partition(Partition.build(partition))
          defaults['partitions'] << partition
        end
      end

      # @api private For internal use only.
      def clear
        default_partition_list.clear
        defaults['partitions'].clear
      end

      # @return [PartitionList]
      # @api private
      def default_partition_list
        @default_partition_list ||= PartitionList.build(defaults)
      end

      # @return [Hash]
      # @api private
      def defaults
        @defaults ||= begin
          path = File.expand_path('../../partitions.json', __FILE__)
          JSON.load(File.read(path))
        end
      end

      # @return [Hash<String,String>] Returns a map of service module names
      #   to their id as used in the endpoints.json document.
      # @api private For internal use only.
      def service_ids
        @service_ids ||= begin
          # service ids
          {
            'ACM' => 'acm',
            'ACMPCA' => 'acm-pca',
            'APIGateway' => 'apigateway',
            'AlexaForBusiness' => 'a4b',
            'AppStream' => 'appstream2',
            'AppSync' => 'appsync',
            'ApplicationAutoScaling' => 'application-autoscaling',
            'ApplicationDiscoveryService' => 'discovery',
            'Athena' => 'athena',
            'AutoScaling' => 'autoscaling',
            'AutoScalingPlans' => 'autoscaling',
            'Batch' => 'batch',
            'Budgets' => 'budgets',
            'Cloud9' => 'cloud9',
            'CloudDirectory' => 'clouddirectory',
            'CloudFormation' => 'cloudformation',
            'CloudFront' => 'cloudfront',
            'CloudHSM' => 'cloudhsm',
            'CloudHSMV2' => 'cloudhsmv2',
            'CloudSearch' => 'cloudsearch',
            'CloudTrail' => 'cloudtrail',
            'CloudWatch' => 'monitoring',
            'CloudWatchEvents' => 'events',
            'CloudWatchLogs' => 'logs',
            'CodeBuild' => 'codebuild',
            'CodeCommit' => 'codecommit',
            'CodeDeploy' => 'codedeploy',
            'CodePipeline' => 'codepipeline',
            'CodeStar' => 'codestar',
            'CognitoIdentity' => 'cognito-identity',
            'CognitoIdentityProvider' => 'cognito-idp',
            'CognitoSync' => 'cognito-sync',
            'Comprehend' => 'comprehend',
            'ConfigService' => 'config',
            'Connect' => 'connect',
            'CostExplorer' => 'ce',
            'CostandUsageReportService' => 'cur',
            'DAX' => 'dax',
            'DataPipeline' => 'datapipeline',
            'DatabaseMigrationService' => 'dms',
            'DeviceFarm' => 'devicefarm',
            'DirectConnect' => 'directconnect',
            'DirectoryService' => 'ds',
            'DynamoDB' => 'dynamodb',
            'DynamoDBStreams' => 'streams.dynamodb',
            'EC2' => 'ec2',
            'ECR' => 'ecr',
            'ECS' => 'ecs',
            'EFS' => 'elasticfilesystem',
            'EMR' => 'elasticmapreduce',
            'ElastiCache' => 'elasticache',
            'ElasticBeanstalk' => 'elasticbeanstalk',
            'ElasticLoadBalancing' => 'elasticloadbalancing',
            'ElasticLoadBalancingV2' => 'elasticloadbalancing',
            'ElasticTranscoder' => 'elastictranscoder',
            'ElasticsearchService' => 'es',
            'FMS' => 'fms',
            'Firehose' => 'firehose',
            'GameLift' => 'gamelift',
            'Glacier' => 'glacier',
            'Glue' => 'glue',
            'Greengrass' => 'greengrass',
            'GuardDuty' => 'guardduty',
            'Health' => 'health',
            'IAM' => 'iam',
            'ImportExport' => 'importexport',
            'Inspector' => 'inspector',
            'IoT' => 'iot',
            'IoTJobsDataPlane' => 'data.jobs.iot',
            'KMS' => 'kms',
            'Kinesis' => 'kinesis',
            'KinesisAnalytics' => 'kinesisanalytics',
            'KinesisVideo' => 'kinesisvideo',
            'KinesisVideoArchivedMedia' => 'kinesisvideo',
            'KinesisVideoMedia' => 'kinesisvideo',
            'Lambda' => 'lambda',
            'LambdaPreview' => 'lambda',
            'Lex' => 'runtime.lex',
            'LexModelBuildingService' => 'models.lex',
            'Lightsail' => 'lightsail',
            'MQ' => 'mq',
            'MTurk' => 'mturk-requester',
            'MachineLearning' => 'machinelearning',
            'MarketplaceCommerceAnalytics' => 'marketplacecommerceanalytics',
            'MarketplaceEntitlementService' => 'entitlement.marketplace',
            'MarketplaceMetering' => 'metering.marketplace',
            'MediaConvert' => 'mediaconvert',
            'MediaLive' => 'medialive',
            'MediaPackage' => 'mediapackage',
            'MediaStore' => 'mediastore',
            'MediaStoreData' => 'data.mediastore',
            'MigrationHub' => 'mgh',
            'Mobile' => 'mobile',
            'OpsWorks' => 'opsworks',
            'OpsWorksCM' => 'opsworks-cm',
            'Organizations' => 'organizations',
            'Pinpoint' => 'pinpoint',
            'Polly' => 'polly',
            'Pricing' => 'api.pricing',
            'RDS' => 'rds',
            'Redshift' => 'redshift',
            'Rekognition' => 'rekognition',
            'ResourceGroups' => 'resource-groups',
            'ResourceGroupsTaggingAPI' => 'tagging',
            'Route53' => 'route53',
            'Route53Domains' => 'route53domains',
            'S3' => 's3',
            'SES' => 'email',
            'SMS' => 'sms',
            'SNS' => 'sns',
            'SQS' => 'sqs',
            'SSM' => 'ssm',
            'STS' => 'sts',
            'SWF' => 'swf',
            'SageMaker' => 'sagemaker',
            'SageMakerRuntime' => 'runtime.sagemaker',
            'SecretsManager' => 'secretsmanager',
            'ServerlessApplicationRepository' => 'serverlessrepo',
            'ServiceCatalog' => 'servicecatalog',
            'ServiceDiscovery' => 'servicediscovery',
            'Shield' => 'shield',
            'SimpleDB' => 'sdb',
            'Snowball' => 'snowball',
            'States' => 'states',
            'StorageGateway' => 'storagegateway',
            'Support' => 'support',
            'TranscribeService' => 'transcribe',
            'Translate' => 'translate',
            'WAF' => 'waf',
            'WAFRegional' => 'waf-regional',
            'WorkDocs' => 'workdocs',
            'WorkMail' => 'workmail',
            'WorkSpaces' => 'workspaces',
            'XRay' => 'xray',
          }
          # end service ids
        end
      end

    end
  end
end
