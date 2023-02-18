require 'rails_helper'

RSpec.describe PostStatusService, type: :service do
  subject { PostStatusService.new }

  it 'creates a new status' do
    account = Fabricate(:account)
    text = 'test status update'

    status = subject.call(account, text: text)

    expect(status).to be_persisted
    expect(status.text).to eq text
  end

  it 'creates a new response status' do
    in_reply_to_status = Fabricate(:status)
    account = Fabricate(:account)
    text = 'test status update'

    status = subject.call(account, text: text, thread: in_reply_to_status)

    expect(status).to be_persisted
    expect(status.text).to eq text
    expect(status.thread).to eq in_reply_to_status
  end

  context 'when scheduling a status' do
    let!(:account)         { Fabricate(:account) }
    let!(:future)          { Time.now.utc + 2.hours }
    let!(:previous_status) { Fabricate(:status, account: account) }

    it 'schedules a status' do
      status = subject.call(account, text: 'Hi future!', scheduled_at: future)
      expect(status).to be_a ScheduledStatus
      expect(status.scheduled_at).to eq future
      expect(status.params['text']).to eq 'Hi future!'
    end

    it 'does not immediately create a status' do
      media = Fabricate(:media_attachment, account: account)
      status = subject.call(account, text: 'Hi future!', media_ids: [media.id], scheduled_at: future)

      expect(status).to be_a ScheduledStatus
      expect(status.scheduled_at).to eq future
      expect(status.params['text']).to eq 'Hi future!'
      expect(status.params['media_ids']).to eq [media.id]
      expect(media.reload.status).to be_nil
      expect(Status.where(text: 'Hi future!').exists?).to be_falsey
    end

    it 'does not change statuses count' do
      expect { subject.call(account, text: 'Hi future!', scheduled_at: future, thread: previous_status) }.not_to change { [account.statuses_count, previous_status.replies_count] }
    end
  end

  it 'creates response to the original status of boost' do
    boosted_status = Fabricate(:status)
    in_reply_to_status = Fabricate(:status, reblog: boosted_status)
    account = Fabricate(:account)
    text = 'test status update'

    status = subject.call(account, text: text, thread: in_reply_to_status)

    expect(status).to be_persisted
    expect(status.text).to eq text
    expect(status.thread).to eq boosted_status
  end

  it 'creates a sensitive status' do
    status = create_status_with_options(sensitive: true)

    expect(status).to be_persisted
    expect(status).to be_sensitive
  end

  it 'creates a status with spoiler text' do
    spoiler_text = 'spoiler text'

    status = create_status_with_options(spoiler_text: spoiler_text)

    expect(status).to be_persisted
    expect(status.spoiler_text).to eq spoiler_text
  end

  it 'creates a sensitive status when there is a CW but no text' do
    status = subject.call(Fabricate(:account), text: '', spoiler_text: 'foo')

    expect(status).to be_persisted
    expect(status).to be_sensitive
  end

  it 'creates a status with empty default spoiler text' do
    status = create_status_with_options(spoiler_text: nil)

    expect(status).to be_persisted
    expect(status.spoiler_text).to eq ''
  end

  it 'creates a status with the given visibility' do
    status = create_status_with_options(visibility: :private)

    expect(status).to be_persisted
    expect(status.visibility).to eq 'private'
  end

  it 'creates a status with limited visibility for silenced users' do
    status = subject.call(Fabricate(:account, silenced: true), text: 'test', visibility: :public)

    expect(status).to be_persisted
    expect(status.visibility).to eq 'unlisted'
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

    status = subject.call(account, text: text)

    expect(status.language).to eq 'en'
  end

  it 'processes mentions' do
    mention_service = double(:process_mentions_service)
    allow(mention_service).to receive(:call)
    allow(ProcessMentionsService).to receive(:new).and_return(mention_service)
    account = Fabricate(:account)

    status = subject.call(account, text: 'test status update')

    expect(ProcessMentionsService).to have_received(:new)
    expect(mention_service).to have_received(:call).with(status, save_records: false)
  end

  it 'safeguards mentions' do
    account = Fabricate(:account)
    mentioned_account = Fabricate(:account, username: 'alice')
    unexpected_mentioned_account = Fabricate(:account, username: 'bob')

    expect do
      subject.call(account, text: '@alice hm, @bob is really annoying lately', allowed_mentions: [mentioned_account.id])
    end.to raise_error(an_instance_of(PostStatusService::UnexpectedMentionsError).and(having_attributes(accounts: [unexpected_mentioned_account])))
  end

  it 'processes duplicate mentions correctly' do
    account = Fabricate(:account)
    mentioned_account = Fabricate(:account, username: 'alice')

    expect do
      subject.call(account, text: '@alice @alice @alice hey @alice')
    end.not_to raise_error
  end

  it 'processes hashtags' do
    hashtags_service = double(:process_hashtags_service)
    allow(hashtags_service).to receive(:call)
    allow(ProcessHashtagsService).to receive(:new).and_return(hashtags_service)
    account = Fabricate(:account)

    status = subject.call(account, text: 'test status update')

    expect(ProcessHashtagsService).to have_received(:new)
    expect(hashtags_service).to have_received(:call).with(status)
  end

  it 'gets distributed' do
    allow(DistributionWorker).to receive(:perform_async)
    allow(ActivityPub::DistributionWorker).to receive(:perform_async)

    account = Fabricate(:account)

    status = subject.call(account, text: 'test status update')

    expect(DistributionWorker).to have_received(:perform_async).with(status.id)
    expect(ActivityPub::DistributionWorker).to have_received(:perform_async).with(status.id)
  end

  it 'crawls links' do
    allow(LinkCrawlWorker).to receive(:perform_async)
    account = Fabricate(:account)

    status = subject.call(account, text: 'test status update')

    expect(LinkCrawlWorker).to have_received(:perform_async).with(status.id)
  end

  it 'attaches the given media to the created status' do
    account = Fabricate(:account)
    media = Fabricate(:media_attachment, account: account)

    status = subject.call(
      account,
      text: 'test status update',
      media_ids: [media.id]
    )

    expect(media.reload.status).to eq status
  end

  it 'does not attach media from another account to the created status' do
    account = Fabricate(:account)
    media = Fabricate(:media_attachment, account: Fabricate(:account))

    status = subject.call(
      account,
      text: 'test status update',
      media_ids: [media.id]
    )

    expect(media.reload.status).to eq nil
  end

  it 'does not allow attaching more than 4 files' do
    account = Fabricate(:account)

    expect do
      subject.call(
        account,
        text: 'test status update',
        media_ids: [
          Fabricate(:media_attachment, account: account),
          Fabricate(:media_attachment, account: account),
          Fabricate(:media_attachment, account: account),
          Fabricate(:media_attachment, account: account),
          Fabricate(:media_attachment, account: account),
        ].map(&:id)
      )
    end.to raise_error(
      Mastodon::ValidationError,
      I18n.t('media_attachments.validations.too_many')
    )
  end

  it 'does not allow attaching both videos and images' do
    account = Fabricate(:account)
    video   = Fabricate(:media_attachment, type: :video, account: account)
    image   = Fabricate(:media_attachment, type: :image, account: account)

    video.update(type: :video)

    expect do
      subject.call(
        account,
        text: 'test status update',
        media_ids: [
          video,
          image,
        ].map(&:id)
      )
    end.to raise_error(
      Mastodon::ValidationError,
      I18n.t('media_attachments.validations.images_and_video')
    )
  end

  it 'returns existing status when used twice with idempotency key' do
    account = Fabricate(:account)
    status1 = subject.call(account, text: 'test', idempotency: 'meepmeep')
    status2 = subject.call(account, text: 'test', idempotency: 'meepmeep')
    expect(status2.id).to eq status1.id
  end

  def create_status_with_options(**options)
    subject.call(Fabricate(:account), options.merge(text: 'test'))
  end
end
