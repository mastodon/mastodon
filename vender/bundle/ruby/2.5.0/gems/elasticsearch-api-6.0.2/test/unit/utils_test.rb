# encoding: UTF-8

require 'test_helper'

module Elasticsearch
  module Test
    class UtilsTest < ::Test::Unit::TestCase
      include Elasticsearch::API::Utils

      context "Utils" do

        context "__escape" do

          should "encode Unicode characters" do
            assert_equal '%E4%B8%AD%E6%96%87', __escape('中文')
          end

          should "encode special characters" do
            assert_equal 'foo+bar',   __escape('foo bar')
            assert_equal 'foo%2Fbar', __escape('foo/bar')
            assert_equal 'foo%5Ebar', __escape('foo^bar')
          end

          should "not encode asterisks" do
            assert_equal '*', __escape('*')
          end

          should "use CGI.escape by default" do
            CGI.expects(:escape)
            __escape('foo bar')
          end

          should "use the escape_utils gem when available" do
            require 'escape_utils'
            CGI.expects(:escape).never
            EscapeUtils.expects(:escape_url)
            __escape('foo bar')
          end unless RUBY_1_8 || JRUBY

        end

        context "__listify" do

          should "create a list from single value" do
            assert_equal 'foo', __listify('foo')
          end

          should "create a list from an array" do
            assert_equal 'foo,bar', __listify(['foo', 'bar'])
          end

          should "create a list from multiple arguments" do
            assert_equal 'foo,bar', __listify('foo', 'bar')
          end

          should "ignore nil values" do
            assert_equal 'foo,bar', __listify(['foo', nil, 'bar'])
          end

          should "encode special characters" do
            assert_equal 'foo,bar%5Ebam', __listify(['foo', 'bar^bam'])
          end

          should "not encode special characters when the :escape option is set" do
            assert_equal 'foo,bar^bam', __listify(['foo', 'bar^bam'], :escape => false)
          end

        end

        context "__pathify" do

          should "create a path from single value" do
            assert_equal 'foo', __pathify('foo')
          end

          should "create a path from an array" do
            assert_equal 'foo/bar', __pathify(['foo', 'bar'])
          end

          should "ignore nil values" do
            assert_equal 'foo/bar', __pathify(['foo', nil, 'bar'])
          end

          should "ignore empty string values" do
            assert_equal 'foo/bar', __pathify(['foo', '', 'bar'])
          end

        end

        context "__bulkify" do

          should "serialize array of hashes" do
            result = Elasticsearch::API::Utils.__bulkify [
              { :index =>  { :_index => 'myindexA', :_type => 'mytype', :_id => '1', :data => { :title => 'Test' } } },
              { :update => { :_index => 'myindexB', :_type => 'mytype', :_id => '2', :data => { :doc => { :title => 'Update' } } } },
              { :delete => { :_index => 'myindexC', :_type => 'mytypeC', :_id => '3' } }
            ]

            if RUBY_1_8
              lines = result.split("\n")

              assert_equal 5, lines.size
              assert_match /\{"index"\:\{/, lines[0]
              assert_match /\{"title"\:"Test"/, lines[1]
              assert_match /\{"update"\:\{/, lines[2]
              assert_match /\{"doc"\:\{"title"/, lines[3]
            else
              assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), result
                {"index":{"_index":"myindexA","_type":"mytype","_id":"1"}}
                {"title":"Test"}
                {"update":{"_index":"myindexB","_type":"mytype","_id":"2"}}
                {"doc":{"title":"Update"}}
                {"delete":{"_index":"myindexC","_type":"mytypeC","_id":"3"}}
              PAYLOAD
            end
          end

          should "serialize arrays of strings" do
            result = Elasticsearch::API::Utils.__bulkify ['{"foo":"bar"}','{"moo":"bam"}']
            assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), result
              {"foo":"bar"}
              {"moo":"bam"}
            PAYLOAD
          end

          should "serialize arrays of header/data pairs" do
            result = Elasticsearch::API::Utils.__bulkify [{:foo => "bar"},{:moo => "bam"},{:foo => "baz"}]
            assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), result
              {"foo":"bar"}
              {"moo":"bam"}
              {"foo":"baz"}
            PAYLOAD
          end

          should "not modify the original payload with the data option" do
            original = [ { :index => {:foo => 'bar', :data => {:moo => 'bam'} } } ]
            result = Elasticsearch::API::Utils.__bulkify original
            assert_not_nil original.first[:index][:data], "Deleted :data from #{original}"
            assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), result
              {"index":{"foo":"bar"}}
              {"moo":"bam"}
            PAYLOAD
          end

          should "not modify the original payload with meta/data pairs" do
            original = [ { :index => {:foo => 'bar'} }, { :data => {:a => 'b', :data => {:c => 'd'} } } ]
            result = Elasticsearch::API::Utils.__bulkify original

            assert_not_nil original.last[:data], "Deleted :data from #{original}"
            assert_not_nil original.last[:data][:data], "Deleted :data from #{original}"

            lines = result.split("\n")
            assert_equal 2, lines.size

            header = MultiJson.load(lines.first)
            data   = MultiJson.load(lines.last)

            assert_equal 'bar', header['index']['foo']
            assert_equal 'b',   data['data']['a']
            assert_equal 'd',   data['data']['data']['c']
          end
        end

        context "__validate_and_extract_params" do
          teardown do
            Elasticsearch::API.settings.clear
          end

          should "extract valid params from a Hash" do
            assert_equal( {:foo => 'qux'},
                         __validate_and_extract_params({ :foo => 'qux' }, [:foo, :bar]) )
          end

          should "raise an exception when invalid keys present" do
            assert_raise ArgumentError do
              __validate_and_extract_params({ :foo => 'qux', :bam => 'mux' }, [:foo, :bar])
            end
          end

          should "not raise an exception for COMMON_PARAMS" do
            assert_nothing_raised do
              __validate_and_extract_params({ :index => 'foo'}, [:foo])
            end
          end

          should "extract COMMON_QUERY_PARAMS" do
            assert_equal( { :format => 'yaml' },
                          __validate_and_extract_params( { :format => 'yaml' } ) )
          end

          should "not validate parameters when the option is set" do
            assert_nothing_raised do
              result = __validate_and_extract_params( { :foo => 'q', :bam => 'm' }, [:foo, :bar], { :skip_parameter_validation => true } )
              assert_equal( { :foo => 'q', :bam => 'm' }, result )
            end
          end

          should "not validate parameters when the module setting is set" do
            assert_nothing_raised do
              Elasticsearch::API.settings[:skip_parameter_validation] = true
              result = __validate_and_extract_params( { :foo => 'q', :bam => 'm' }, [:foo, :bar] )
              assert_equal( { :foo => 'q', :bam => 'm' }, result )
            end
          end

          should "listify Arrays" do
            result = __validate_and_extract_params( { :foo => ['a', 'b'] }, [:foo] )
            assert_equal( { :foo => 'a,b'}, result )
          end

          should "not escape the parameters" do
            result = __validate_and_extract_params( { :foo => ['a.*', 'b.*'] }, [:foo] )
            assert_equal( { :foo => 'a.*,b.*'}, result )
          end
        end

        context "__extract_parts" do

          should "extract parts with true value from a Hash" do
            assert_equal( ['foo'], __extract_parts({ :foo => true, :moo => 'blah' }, [:foo, :bar]) )
          end

          should "extract parts with string value from a Hash" do
            assert_equal( ['qux'], __extract_parts({ :foo => 'qux', :moo => 'blah' }, [:foo, :bar]) )
          end

        end

        context "__rescue_from_not_found" do

          should "return false if exception class name contains 'NotFound'" do
            assert_equal( false, __rescue_from_not_found { raise NotFound })
          end

          should "return false if exception message contains 'Not Found'" do
            assert_equal( false, __rescue_from_not_found { raise StandardError.new "Not Found" })
            assert_equal( false, __rescue_from_not_found { raise StandardError.new "NotFound" })
          end

          should "raise exception if exception class name and message do not contain NotFound/404" do
            assert_raise StandardError do
              __rescue_from_not_found { raise StandardError.new "Any other exception" }
            end
          end

        end

        context "__report_unsupported_parameters" do
          should "print used unsupported parameters passed as Symbols" do
            arguments = { :foo => 'bar', :moo => 'bam', :baz => 'qux' }
            unsupported_params = [:foo, :moo]

            Kernel.expects(:warn).with do |message|
              assert_equal 2, message.split("\n").reject { |l| l.include? 'Suppress this warning' }.size
              true
            end

            __report_unsupported_parameters(arguments, unsupported_params)
          end

          should "print used unsupported parameters passed as Hashes" do
            arguments = { :foo => 'bar', :moo => 'bam', :baz => 'qux' }
            unsupported_params = [ { :foo => { :explanation => 'NOT_SUPPORTED' } } ]

            Kernel.expects(:warn).with do |message|
              assert_match /NOT_SUPPORTED/, message
              assert_equal 1, message.split("\n").reject { |l| l.include? 'Suppress this warning' }.size
              true
            end

            __report_unsupported_parameters(arguments, unsupported_params)
          end

          should "print used unsupported parameters passed as a mix of Symbols and Hashes" do
            arguments = { :foo => 'bar', :moo => 'bam', :baz => 'qux' }
            unsupported_params = [ { :foo => { :explanation => 'NOT_SUPPORTED'} }, :moo ]

            Kernel.expects(:warn).with do |message|
              assert_match /NOT_SUPPORTED/, message
              assert_equal 2, message.split("\n").reject { |l| l.include? 'Suppress this warning' }.size
              true
            end

            __report_unsupported_parameters(arguments, unsupported_params)
          end

          should "not print unused unsupported parameters" do
            arguments = { :moo => 'bam', :baz => 'qux' }
            unsupported_params = [:foo]

            Kernel.expects(:warn).never

            __report_unsupported_parameters(arguments, unsupported_params)
          end
        end

        context "__report_unsupported_method" do
          should "print the warning" do
            Kernel.expects(:warn).with do |message|
              assert_match /foo/, message
              true
            end

            __report_unsupported_method(:foo)
          end
        end
      end
    end
  end
end
