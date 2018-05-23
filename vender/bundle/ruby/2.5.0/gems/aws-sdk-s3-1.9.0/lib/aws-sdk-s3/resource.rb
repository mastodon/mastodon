# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::S3
  class Resource

    # @param options ({})
    # @option options [Client] :client
    def initialize(options = {})
      @client = options[:client] || Client.new(options)
    end

    # @return [Client]
    def client
      @client
    end

    # @!group Actions

    # @example Request syntax with placeholder values
    #
    #   bucket = s3.create_bucket({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     bucket: "BucketName", # required
    #     create_bucket_configuration: {
    #       location_constraint: "EU", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
    #     },
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #   })
    # @param [Hash] options ({})
    # @option options [String] :acl
    #   The canned ACL to apply to the bucket.
    # @option options [required, String] :bucket
    # @option options [Types::CreateBucketConfiguration] :create_bucket_configuration
    # @option options [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    # @option options [String] :grant_read
    #   Allows grantee to list the objects in the bucket.
    # @option options [String] :grant_read_acp
    #   Allows grantee to read the bucket ACL.
    # @option options [String] :grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    # @option options [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    # @return [Bucket]
    def create_bucket(options = {})
      resp = @client.create_bucket(options)
      Bucket.new(
        name: options[:bucket],
        client: @client
      )
    end

    # @!group Associations

    # @param [String] name
    # @return [Bucket]
    def bucket(name)
      Bucket.new(
        name: name,
        client: @client
      )
    end

    # @example Request syntax with placeholder values
    #
    #   s3.buckets()
    # @param [Hash] options ({})
    # @return [Bucket::Collection]
    def buckets(options = {})
      batches = Enumerator.new do |y|
        batch = []
        resp = @client.list_buckets(options)
        resp.data.buckets.each do |b|
          batch << Bucket.new(
            name: b.name,
            data: b,
            client: @client
          )
        end
        y.yield(batch)
      end
      Bucket::Collection.new(batches)
    end

  end
end
