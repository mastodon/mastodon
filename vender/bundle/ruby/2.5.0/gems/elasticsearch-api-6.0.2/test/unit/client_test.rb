require 'test_helper'

module Elasticsearch
  module Test
    class ClientTest < ::Test::Unit::TestCase

      context "API Client" do

        class MyDummyClient
          include Elasticsearch::API
        end

        subject { MyDummyClient.new }

        should "have the cluster namespace" do
          assert_respond_to subject, :cluster
        end

        should "have the indices namespace" do
          assert_respond_to subject, :indices
        end

        should "have API methods" do
          assert_respond_to subject, :bulk
        end

      end

    end
  end
end
