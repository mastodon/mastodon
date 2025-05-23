# frozen_string_literal: true

# app/services/locutus/fetch_scores_service.rb
module Locutus
  class FetchScoresService < BaseService
    SCORE_API_URI = URI('http://67.207.93.201:5001/analysis/batched-get-score')

    def self.call(status_ids:, user_ids:)
      new.call(status_ids: status_ids, user_ids: user_ids)
    end

    # @param status_ids [Array<Integer>] List of status IDs to fetch scores for
    # @param user_ids [Array<Integer>] List of user IDs to fetch scores for
    # @return [Hash<Integer, Hash<Integer, Float>>] A hash mapping status_id -> user_id -> score
    def call(status_ids:, user_ids:)
      http    = Net::HTTP.new(SCORE_API_URI.host, SCORE_API_URI.port)
      request = Net::HTTP::Get.new(SCORE_API_URI.path, 'Content-Type' => 'application/json')
      request.body = { status_ids: status_ids.map(&:to_s), user_ids: user_ids.map(&:to_s) }.to_json

      response = http.request(request)
      raise "Score API error: #{response.code} #{response.body}" unless response.code == '200'

      # Parse the response into a Hash<status_id, Hash<user_id, score>>
      scores = JSON.parse(response.body)['scores']
      scores.transform_keys!(&:to_i)
      scores.each_value { |user_scores| user_scores.transform_keys!(&:to_i) }
      scores
    end
  end
end