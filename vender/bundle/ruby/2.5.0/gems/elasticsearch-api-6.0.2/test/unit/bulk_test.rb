require 'test_helper'

module Elasticsearch
  module Test
    class BulkTest < ::Test::Unit::TestCase

      context "Bulk" do
        subject { FakeClient.new }

        should "post correct payload to the endpoint" do
          subject.expects(:perform_request).with do |method, url, params, body, headers|
            assert_equal 'POST', method
            assert_equal '_bulk', url
            assert_equal Hash.new, params

            if RUBY_1_8
              lines = body.split("\n")

              assert_equal 7, lines.size
              assert_match /\{"index"\:\{/, lines[0]
              assert_match /\{"title"\:"Test"/, lines[1]
              assert_match /\{"update"\:\{/, lines[2]
              assert_match /\{"doc"\:\{"title"/, lines[3]
            else
              assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), body
                {"index":{"_index":"myindexA","_type":"mytype","_id":"1"}}
                {"title":"Test"}
                {"update":{"_index":"myindexB","_type":"mytype","_id":"2"}}
                {"doc":{"title":"Update"}}
                {"delete":{"_index":"myindexC","_type":"mytypeC","_id":"3"}}
                {"index":{"_index":"myindexD","_type":"mytype","_id":"1"}}
                {"data":"MYDATA"}
              PAYLOAD
            end
            assert_equal 'application/x-ndjson', headers["Content-Type"]
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => [
            { :index =>  { :_index => 'myindexA', :_type => 'mytype', :_id => '1', :data => { :title => 'Test' } } },
            { :update => { :_index => 'myindexB', :_type => 'mytype', :_id => '2', :data => { :doc => { :title => 'Update' } } } },
            { :delete => { :_index => 'myindexC', :_type => 'mytypeC', :_id => '3' } },
            { :index =>  { :_index => 'myindexD', :_type => 'mytype', :_id => '1', :data => { :data => 'MYDATA' } } },
          ]
        end

        should "post payload to the correct endpoint" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'myindex/_bulk', url
            true
          end.returns(FakeResponse.new)

          subject.bulk :index => 'myindex', :body => []
        end

        should "handle `:data` keys correctly in header/data payloads" do
          subject.expects(:perform_request).with do |method, url, params, body|
            lines = body.split("\n")
            assert_equal 2, lines.size

            header = MultiJson.load(lines.first)
            data   = MultiJson.load(lines.last)

            assert_equal 'myindex', header['update']['_index']
            assert_equal 'mytype',  header['update']['_type']
            assert_equal '1',       header['update']['_id']

            assert_equal({'data' => { 'title' => 'Update' }}, data['doc'])
            # assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), body
            #   {"update":{"_index":"myindex","_type":"mytype","_id":"1"}}
            #   {"doc":{"data":{"title":"Update"}}}
            # PAYLOAD
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => [
            { :update => { :_index => 'myindex', :_type => 'mytype', :_id => '1' } },
            { :doc => { :data => { :title => 'Update' } } }
          ]
        end

        should "post a string payload" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal "foo\nbar", body
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => "foo\nbar"
        end

        should "post an array of strings payload" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal "foo\nbar\n", body
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => ["foo", "bar"]
        end

        should "encode URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_bulk', url
            assert_equal({:refresh => true}, params)
            true
          end.returns(FakeResponse.new)

          subject.bulk :refresh => true, :body => []
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_bulk', url
            true
          end.returns(FakeResponse.new)

          subject.bulk :index => 'foo^bar', :body => []
        end

        should "not duplicate the type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'myindex/mytype/_bulk', url
            assert_empty params
            true
          end.returns(FakeResponse.new)

          subject.bulk :index => 'myindex', :type => 'mytype', :body => []
        end

      end

    end
  end
end
