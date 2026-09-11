# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elasticsearch::ClientExtensions do
  describe '#initialize' do
    it 'marks the connection as verified on initialization' do
      client = Elasticsearch::Client.new

      expect(client.instance_variable_get(:@verified))
        .to be(true)
    end
  end
end
