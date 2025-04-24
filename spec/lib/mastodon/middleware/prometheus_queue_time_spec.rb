# frozen_string_literal: true

require 'rails_helper'
require 'prometheus_exporter'
require 'prometheus_exporter/middleware'
require 'mastodon/middleware/prometheus_queue_time'

RSpec.describe Mastodon::Middleware::PrometheusQueueTime do
  subject { described_class.new(app, client:) }

  let(:app) do
    proc { |_env| [200, {}, 'OK'] }
  end
  let(:client) do
    instance_double(PrometheusExporter::Client, send_json: true)
  end

  describe '#call' do
    let(:env) do
      {
        'HTTP_X_REQUEST_START' => "t=#{(Time.now.to_f * 1000).to_i}",
      }
    end

    it 'reports a queue time to the client' do
      subject.call(env)

      expect(client).to have_received(:send_json)
        .with(hash_including(queue_time: instance_of(Float)))
    end
  end
end
