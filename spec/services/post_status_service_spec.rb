require 'rails_helper'

RSpec.describe PostStatusService, type: :service do
  subject { PostStatusService.new }

  it 'creates a new status' do
    account = Fabricate(:account)
    text = "test status update"

    status = subject.call(account, text)

    expect(status).to be_persisted
    expect(status.text).to eq text
  end

  it 'creates a new response status' do
    in_reply_to_status = Fabricate(:status)
    account = Fabricate(:account)
    text = "test status update"

    status = subject.call(account, text, in_reply_to_status)

    expect(status).to be_persisted
    expect(status.text).to eq text
    expect(status.thread).to eq in_reply_to_status
  end

  it 'creates a sensitive status' do
    status = create_status_with_options(sensitive: true)

    expect(status).to be_persisted
    expect(status).to be_sensitive
  end

  it 'creates a status with spoiler text' do
    spoiler_text = "spoiler text"

    status = create_status_with_options(spoiler_text: spoiler_text)

    expect(status).to be_persisted
    expect(status.spoiler_text).to eq spoiler_text
  end

  it 'creates a status with empty default spoiler text' do
    status = create_status_with_options(spoiler_text: nil)

    expect(status).to be_persisted
    expect(status.spoiler_text).to eq ''
  end

  it 'creates a status with the given visibility' do
    status = create_status_with_options(visibility: :private)

    expect(status).to be_persisted
    expect(status.visibility).to eq "private"
  end

  it 'creates a status for the given application' do
    application = Fabricate(:application)

    status = create_status_with_options(application: application)

    expect(status).to be_persisted
    expect(status.application).to eq application
  end

  it 'creates a status with a language set' do
    account = Fabricate(:account)
    text = 'This is an English text.'

    status = subject.call(account, text)

    expect(status.language).to eq 'en'
  end

  it 'processes mentions' do
    mention_service = double(:process_mentions_service)
    allow(mention_service).to receive(:call)
    allow(ProcessMentionsService).to receive(:new).and_return(mention_service)
    account = Fabricate(:account)

    status = subject.call(account, "test status update")

    expect(ProcessMentionsService).to have_received(:new)
    expect(mention_service).to have_received(:call).with(status)
  end

  it 'processes hashtags' do
    hashtags_service = double(:process_hashtags_service)
    allow(hashtags_service).to receive(:call)
    allow(ProcessHashtagsService).to receive(:new).and_return(hashtags_service)
    account = Fabricate(:account)

    status = subject.call(account, "test status update")

    expect(ProcessHashtagsService).to have_received(:new)
    expect(hashtags_service).to have_received(:call).with(status)
  end

  it 'gets distributed' do
    allow(DistributionWorker).to receive(:perform_async)
    allow(Pubsubhubbub::DistributionWorker).to receive(:perform_async)
    allow(ActivityPub::DistributionWorker).to receive(:perform_async)

    account = Fabricate(:account)

    status = subject.call(account, "test status update")

    expect(DistributionWorker).to have_received(:perform_async).with(status.id)
    expect(Pubsubhubbub::DistributionWorker).to have_received(:perform_async).with(status.stream_entry.id)
    expect(ActivityPub::DistributionWorker).to have_received(:perform_async).with(status.id)
  end

  it 'crawls links' do
    allow(LinkCrawlWorker).to receive(:perform_async)
    account = Fabricate(:account)

    status = subject.call(account, "test status update")

    expect(LinkCrawlWorker).to have_received(:perform_async).with(status.id)
  end

  it 'attaches the given media to the created status' do
    account = Fabricate(:account)
    media = Fabricate(:media_attachment)

    status = subject.call(
      account,
      "test status update",
      nil,
      media_ids: [media.id],
    )

    expect(media.reload.status).to eq status
  end

  it 'does not allow attaching more than 4 files' do
    account = Fabricate(:account)

    expect do
      subject.call(
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
      I18n.t('media_attachments.validations.too_many'),
    )
  end

  it 'does not allow attaching both videos and images' do
    account = Fabricate(:account)

    expect do
      subject.call(
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
      I18n.t('media_attachments.validations.images_and_video'),
    )
  end

  it 'returns existing status when used twice with idempotency key' do
    account = Fabricate(:account)
    status1 = subject.call(account, 'test', nil, idempotency: 'meepmeep')
    status2 = subject.call(account, 'test', nil, idempotency: 'meepmeep')
    expect(status2.id).to eq status1.id
  end

  def create_status_with_options(**options)
    subject.call(Fabricate(:account), 'test', nil, options)
  end
end
