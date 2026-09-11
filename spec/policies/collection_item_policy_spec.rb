# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionItemPolicy do
  subject { described_class }

  let(:account) { Fabricate(:account) }

  permissions :revoke? do
    context 'when collection item features the revoking account' do
      let(:collection_item) { Fabricate.build(:collection_item, account:) }

      it { is_expected.to permit(account, collection_item) }
    end

    context 'when collection item does not feature the revoking account' do
      let(:collection_item) { Fabricate.build(:collection_item) }

      it { is_expected.to_not permit(account, collection_item) }
    end
  end
end
