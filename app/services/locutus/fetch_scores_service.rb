# app/services/locutus/fetch_scores_service.rb
class Locutus::FetchScoresService < BaseService
  SCORE_API_URI = URI('http://67.207.93.201:5001/analysis/batched-get-score')

  def self.call(status_ids:, user_ids:)
    new.call(status_ids: status_ids, user_ids: user_ids)
  end

  def call(status_ids:, user_ids:)
    http    = Net::HTTP.new(SCORE_API_URI.host, SCORE_API_URI.port)
    request = Net::HTTP::Get.new(SCORE_API_URI.path, 'Content-Type' => 'application/json')
    request.body = { status_ids: status_ids.map(&:to_s), user_ids: user_ids.map(&:to_s) }.to_json

    response = http.request(request)
    raise "Score API error: #{response.code} #{response.body}" unless response.code == '200'

    JSON.parse(response.body)['scores']
  end
end