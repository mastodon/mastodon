# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailAddressValidator do
  subject { record_class.new }

  context 'with no options' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        def self.name = 'Record'

        attr_accessor :email

        validates :email, email_address: true
      end
    end

    it { is_expected.to allow_value('foo@example.com').for(:email) }
    it { is_expected.to_not allow_value('foo @ example.com').for(:email) }
    it { is_expected.to_not allow_value('foo@example.com%foo.example.com').for(:email) }
  end
end
