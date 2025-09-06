# frozen_string_literal: true

require 'rails_helper'

RSpec.describe URLValidator, type: :model do
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
    it { is_expected.to_not allow_value('ftp://example.com/page').for(:profile).with_message(:invalid) }
  end

  context 'without a hostname' do
    it { is_expected.to_not allow_value('https:///page').for(:profile).with_message(:invalid) }
  end

  context 'with an unparseable value' do
    # The non-numeric port string causes an invalid uri error
    it { is_expected.to_not allow_value('https://host:port/page').for(:profile).with_message(:invalid) }
  end

  context 'with a valid url' do
    it { is_expected.to allow_value('https://example.com/page').for(:profile) }
  end
end
