# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::PartialAccountSerializer do
  subject do
    serialized_record_json(account, described_class, options: {
      scope: nil,
      scope_name: :current_user,
    })
  end

  let(:account) { Fabricate(:account, avatar_description: 'image') }

  it 'includes the expected attributes' do
    expect(subject).to include({
      'id' => account.id.to_s,
      'acct' => account.pretty_acct,
      'locked' => false,
      'bot' => false,
      'url' => ActivityPub::TagManager.instance.url_for(account),
      'avatar' => include(account.avatar_original_url),
      'avatar_static' => include(account.avatar_static_url),
      'avatar_description' => 'image',
    })
  end
end
