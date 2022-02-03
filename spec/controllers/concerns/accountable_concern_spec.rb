# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountableConcern do
  class Hoge
    include AccountableConcern
    attr_reader :current_account

    def initialize(current_account)
      @current_account = current_account
    end
  end

  let(:user)   { Fabricate(:account) }
  let(:target) { Fabricate(:account) }
  let(:hoge)   { Hoge.new(user) }

  describe '#log_action' do
    it 'creates Admin::ActionLog' do
      expect do
        hoge.log_action(:create, target)
      end.to change { Admin::ActionLog.count }.by(1)
    end
  end
end
