# frozen_string_literal: true

require 'rails_helper'

RSpec.describe URLValidator do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      def self.name = 'Record'

      attr_accessor :profile

      validates :profile, url: true
    end
  end

  context 'with a nil value' do
    it { is_expected.to_not allow_value(nil).for(:profile).with_message(:invalid) }
  end

  context 'with an invalid url scheme' do
    let(:invalid_scheme_url) { 'ftp://example.com/page' }

    it { is_expected.to_not allow_value(invalid_scheme_url).for(:profile).with_message(:invalid) }
  end

  context 'without a hostname' do
    let(:no_hostname_url) { 'https:///page' }

    it { is_expected.to_not allow_value(no_hostname_url).for(:profile).with_message(:invalid) }
  end

  context 'with an unparseable value' do
    let(:non_numeric_port_url) { 'https://host:port/page' }

    it { is_expected.to_not allow_value(non_numeric_port_url).for(:profile).with_message(:invalid) }
  end

  context 'with a valid url' do
    let(:valid_url) { 'https://example.com/page' }

    it { is_expected.to allow_value(valid_url).for(:profile) }
  end
end
