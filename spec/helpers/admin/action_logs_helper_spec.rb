# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogsHelper do
  before { sign_in Fabricate(:admin_user) }

  describe '#translation_key' do
    let(:tag) { Fabricate(:tag, name: '#supertag') }
    let(:account) { Fabricate(:account) }
    let!(:log) { Fabricate(:action_log, target: tag, account: account, usable: false, listable: true) }

    it 'returns translation keys for all different states' do
      expect(helper.translation_key(log, :usable)).to eq("#{t('admin.trends.tags.not_usable')};")
      expect(helper.translation_key(log, :trendable)).to be_nil
      expect(helper.translation_key(log, :listable)).to eq("#{t('admin.trends.tags.listable')};")
    end
  end
end
