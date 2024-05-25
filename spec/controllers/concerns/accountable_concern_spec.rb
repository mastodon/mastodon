# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountableConcern do
  let(:hoge_class) do
    Class.new do
      include AccountableConcern
      attr_reader :current_account

      def initialize(current_account)
        @current_account = current_account
      end
    end
  end

  let(:user)   { Fabricate(:account) }
  let(:target) { Fabricate(:account) }
  let(:hoge)   { hoge_class.new(user) }

  describe '#log_action' do
    subject { hoge.log_action(:create, target) }

    before { target.reload } # Ensure changes from creation cleared

    context 'when target has changed' do
      before { target.update!(username: 'new_value') }

      it 'creates Admin::ActionLog' do
        expect { subject }
          .to change(Admin::ActionLog, :count).by(1)
      end
    end

    context 'when target has not changed' do
      it 'does not create Admin::ActionLog' do
        expect { subject }
          .to_not change(Admin::ActionLog, :count)
      end
    end
  end
end
