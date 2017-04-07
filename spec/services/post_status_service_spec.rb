require 'rails_helper'

RSpec.describe PostStatusService do
  subject { PostStatusService.new }

  it 'creates a new status'
  it 'creates a new response status'
  it 'processes mentions'
  it 'pings PuSH hubs'

  it 'does not allow attaching more than 4 files' do
    account = Fabricate(:account)

    expect do
      PostStatusService.new.call(
      account,
      "test status update",
      nil,
      media_ids: [
        Fabricate(:media_attachment, account: account),
        Fabricate(:media_attachment, account: account),
        Fabricate(:media_attachment, account: account),
        Fabricate(:media_attachment, account: account),
        Fabricate(:media_attachment, account: account),
      ].map(&:id),
    )
    end.to raise_error(
      Mastodon::ValidationError,
      'Cannot attach more than 4 files',
    )
  end

  it 'does not allow attaching both videos and images' do
    account = Fabricate(:account)

    expect do
      PostStatusService.new.call(
      account,
      "test status update",
      nil,
      media_ids: [
        Fabricate(:media_attachment, type: :video, account: account),
        Fabricate(:media_attachment, type: :image, account: account),
      ].map(&:id),
    )
    end.to raise_error(
      Mastodon::ValidationError,
      'Cannot attach a video to a toot that already contains images',
    )
  end
end
