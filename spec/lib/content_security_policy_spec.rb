# frozen_string_literal: true

require 'rails_helper'

describe ContentSecurityPolicy do
  subject { described_class.new }

  describe '#base_host' do
    it 'returns the configured value for the web domain' do
      expect(subject.base_host).to eq Rails.configuration.x.web_domain
    end
  end
end
