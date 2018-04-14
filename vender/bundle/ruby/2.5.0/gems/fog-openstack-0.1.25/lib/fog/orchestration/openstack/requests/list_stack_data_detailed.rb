module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_stack_data_detailed(options = {})
          request(
            :method  => 'GET',
            :path    => 'stacks/detail',
            :expects => 200,
            :query   => options
          )
        end
      end

      class Mock
        def list_stack_data_detailed(_options = {})
          Excon::Response.new(
            :body   => {
              'stacks' =>
                          [{"parent"                => nil,
                            "disable_rollback"      => true,
                            "description"           => "No description",
                            "links"                 => [{"href" => "http://192.0.2.1:8004/v1/ae084f19a7974d5b95703f633e57fd64/stacks/overcloud/9ea5226f-0bb3-40bf-924b-f89ea11bb69c",
                                                         "rel"  => "self"}],
                            "stack_status_reason"   => "Stack CREATE completed successfully",
                            "stack_name"            => "overcloud",
                            "stack_user_project_id" => "ae084f19a7974d5b95703f633e57fd64",
                            "stack_owner"           => "admin",
                            "creation_time"         => "2015-06-24T07:19:01Z",
                            "capabilities"          => [],
                            "notification_topics"   => [],
                            "updated_time"          => nil,
                            "timeout_mins"          => nil,
                            "stack_status"          => "CREATE_COMPLETE",
                            "parameters"            => {"Controller-1::SSLKey"                  => "******",
                                                        "Compute-1::RabbitClientUseSSL"         => "False",
                                                        "Controller-1::KeystoneSSLCertificate"  => "",
                                                        "Controller-1::CinderLVMLoopDeviceSize" => "5000"},
                            "id"                    => "9ea5226f-0bb3-40bf-924b-f89ea11bb69c",
                            "outputs"               => [],
                            "template_description"  => "No description"}]
            },
            :status => 200
          )
        end
      end
    end
  end
end
