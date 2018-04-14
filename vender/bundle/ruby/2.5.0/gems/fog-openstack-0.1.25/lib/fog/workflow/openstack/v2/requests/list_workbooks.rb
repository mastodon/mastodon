module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_workbooks
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "workbooks"
            )
          end
        end

        class Mock
          def list_workbooks
            response = Excon::Response.new
            response.status = 200
            response.body = {"workbooks" =>
                                            [{"name" => "workbook1", "description" => "d1"},
                                             {"name" => "workbook2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end
