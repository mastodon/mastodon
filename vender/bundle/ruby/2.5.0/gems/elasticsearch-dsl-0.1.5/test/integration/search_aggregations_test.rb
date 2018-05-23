require 'test_helper'

module Elasticsearch
  module Test
    class AggregationsIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      context "Aggregations integration" do
        setup do
          @client.indices.create index: 'test'
          @client.index index: 'test', type: 'd', id: '1', body: { title: 'A', tags: %w[one], clicks: 5 }
          @client.index index: 'test', type: 'd', id: '2', body: { title: 'B', tags: %w[one two], clicks: 15 }
          @client.index index: 'test', type: 'd', id: '3', body: { title: 'C', tags: %w[one three], clicks: 20 }
          @client.indices.refresh index: 'test'
        end

        context "with a terms aggregation" do
          should "return tag counts" do
            response = @client.search index: 'test', body: search {
              aggregation :tags do
                terms field: 'tags'
              end
            }.to_hash

            assert_equal 3, response['aggregations']['tags']['buckets'].size
            assert_equal 'one', response['aggregations']['tags']['buckets'][0]['key']
          end

          should "return approximate tag counts" do
            response = @client.search index: 'test', body: search {
              aggregation :tags do
                cardinality field: 'tags'
              end
            }.to_hash

            assert_equal 3, response['aggregations']['tags']['value']
          end

          should "return tag counts per clicks range as an inner (nested) aggregation" do
            response = @client.search index: 'test', body: search {
              aggregation :clicks do
                range field: 'clicks' do
                  key :low, to: 10
                  key :mid, from: 10, to: 20

                  aggregation :tags do
                    terms field: 'tags'
                  end
                end
              end
            }.to_hash

            assert_equal 2, response['aggregations']['clicks']['buckets'].size
            assert_equal 1, response['aggregations']['clicks']['buckets']['low']['doc_count']
            assert_equal 'one', response['aggregations']['clicks']['buckets']['low']['tags']['buckets'][0]['key']
          end

          should "define multiple aggregations" do
            response = @client.search index: 'test', body: search {
              aggregation :clicks do
                range field: 'clicks' do
                  key :low, to: 10
                  key :mid, from: 10, to: 20

                  aggregation :tags do
                    terms { field 'tags' }
                  end
                end
              end

              aggregation :min_clicks do
                min field: 'clicks'
              end

              aggregation :max_clicks do
                max field: 'clicks'
              end

              aggregation :sum_clicks do
                sum field: 'clicks'
              end

              aggregation :avg_clicks do
                avg field: 'clicks'
              end
            }.to_hash

            assert_equal 2, response['aggregations']['clicks']['buckets'].size
            assert_equal 1, response['aggregations']['clicks']['buckets']['low']['doc_count']
            assert_equal 'one', response['aggregations']['clicks']['buckets']['low']['tags']['buckets'][0]['key']

            assert_equal 5,  response['aggregations']['min_clicks']['value']
            assert_equal 20, response['aggregations']['max_clicks']['value']
            assert_equal 40, response['aggregations']['sum_clicks']['value']
            assert_equal 13, response['aggregations']['avg_clicks']['value'].to_i
          end

          should "define a global aggregation" do
            response = @client.search index: 'test', body: search {
                query do
                  filtered filter: { terms: { tags: ['two'] } }
                end

                aggregation :avg_clicks do
                  avg field: 'clicks'
                end

                aggregation :all_documents do
                  global do
                    aggregation :avg_clicks do
                      avg field: 'clicks'
                    end
                  end
                end
            }.to_hash

            assert_equal 15, response['aggregations']['avg_clicks']['value'].to_i
            assert_equal 13, response['aggregations']['all_documents']['avg_clicks']['value'].to_i
          end

          should "return statistics on clicks" do
            response = @client.search index: 'test', body: search {
              aggregation :stats_clicks do
                stats field: 'clicks'
              end
              aggregation :value_count do
                value_count field: 'clicks'
              end
            }.to_hash

            assert_equal 3,  response['aggregations']['stats_clicks']['count']
            assert_equal 5,  response['aggregations']['stats_clicks']['min']
            assert_equal 20, response['aggregations']['stats_clicks']['max']
            assert_equal 40, response['aggregations']['stats_clicks']['sum']
            assert_equal 13, response['aggregations']['stats_clicks']['avg'].to_i
            assert_equal 3,  response['aggregations']['value_count']['value']
          end

          should "return percentiles on clicks" do
            response = @client.search index: 'test', body: search {
              aggregation :percentiles do
                percentiles field: 'clicks'
              end
            }.to_hash

            assert_equal 20, response['aggregations']['percentiles']['values']['99.0'].round
          end

          should "return percentile ranks on clicks" do
            response = @client.search index: 'test', body: search {
              aggregation :percentiles do
                percentile_ranks field: 'clicks', values: [5]
              end
            }.to_hash

            assert_equal 17, response['aggregations']['percentiles']['values']['5.0'].round
          end

          should "return top hits per tag" do
            response = @client.search index: 'test', body: search {
              aggregation :tags do
                terms do
                  field 'tags'
                  size  5

                  aggregation :top_hits do
                    top_hits sort: [ clicks: { order: 'desc' } ], _source: { include: 'title' }
                  end
                end
              end
            }.to_hash

            assert_equal 3, response['aggregations']['tags']['buckets'][0]['top_hits']['hits']['hits'].size
            assert_equal 'C', response['aggregations']['tags']['buckets'][0]['top_hits']['hits']['hits'][0]['_source']['title']
          end

          should "calculate clicks for a tag" do
            response = @client.search index: 'test', body: search {
              aggregation :clicks_for_one do
                scripted_metric do
                  init_script "_agg['transactions'] = []"
                  map_script  "if (doc['tags'].value.contains('one')) { _agg.transactions.add(doc['clicks'].value) }"
                  combine_script "sum = 0; for (t in _agg.transactions) { sum += t }; return sum"
                  reduce_script "sum = 0; for (a in _aggs) { sum += a }; return sum"
                end
              end
            }.to_hash

            assert_equal 40, response['aggregations']['clicks_for_one']['value']
          end

          should "limit the scope with a filter" do
            response = @client.search index: 'test', body: search {
              aggregation :clicks_for_one do
                filter terms: { tags: ['one'] } do
                  aggregation :sum_clicks do
                    sum field: 'clicks'
                  end
                end
              end
            }.to_hash

            assert_equal 40, response['aggregations']['clicks_for_one']['sum_clicks']['value']
          end
        end

        should "return aggregations for multiple filters" do
          response = @client.search index: 'test', body: search {
            aggregation :avg_clicks_per_tag do
              filters do
                filters one: { terms: { tags: ['one'] } },
                        two: { terms: { tags: ['two'] } }
                aggregation :avg do
                  avg field: 'clicks'
                end
              end
            end
          }.to_hash

          assert_equal 13, response['aggregations']['avg_clicks_per_tag']['buckets']['one']['avg']['value'].to_i
          assert_equal 15, response['aggregations']['avg_clicks_per_tag']['buckets']['two']['avg']['value'].to_i
        end

        should "return a histogram on clicks" do
          response = @client.search index: 'test', body: search {
            aggregation :clicks_histogram do
              histogram do
                field   'clicks'
                interval 10
              end
            end
          }.to_hash

          assert_equal 3,  response['aggregations']['clicks_histogram']['buckets'].size
          assert_equal 10, response['aggregations']['clicks_histogram']['buckets'][1]['key']
          assert_equal 1,  response['aggregations']['clicks_histogram']['buckets'][1]['doc_count']
        end

        should "return a histogram with empty buckets on clicks" do
          response = @client.search index: 'test', body: search {
            aggregation :clicks_histogram do
              histogram do
                field   'clicks'
                interval 2
                min_doc_count 0
              end
            end
          }.to_hash

          assert_equal 9, response['aggregations']['clicks_histogram']['buckets'].size
        end
      end
    end
  end
end
