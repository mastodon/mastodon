# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostStatusService do
  subject { described_class.new }

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

    it 'schedules a status for future creation and does not create one immediately' do
      media = Fabricate(:media_attachment, account: account)
      status = subject.call(account, text: 'Hi future!', media_ids: [media.id.to_s], scheduled_at: future)

      expect(status)
        .to be_a(ScheduledStatus)
        .and have_attributes(
          scheduled_at: eq(future),
          params: include(
            'text' => eq('Hi future!'),
            'media_ids' => contain_exactly(media.id.to_s)
          )
        )
      expect(media.reload.status).to be_nil
      expect(Status.where(text: 'Hi future!')).to_not exist
    end

    it 'does not change statuses_count of account or replies_count of thread previous status' do
      expect { subject.call(account, text: 'Hi future!', scheduled_at: future, thread: previous_status) }
        .to not_change { account.statuses_count }
        .and(not_change { previous_status.replies_count })
    end

    it 'returns existing status when used twice with idempotency key' do
      account = Fabricate(:account)
      status1 = subject.call(account, text: 'test', idempotency: 'meepmeep', scheduled_at: future)
      status2 = subject.call(account, text: 'test', idempotency: 'meepmeep', scheduled_at: future)
      expect(status2.id).to eq status1.id
    end

    context 'when scheduled_at is less than min offset' do
      let(:invalid_scheduled_time) { 4.minutes.from_now }

      it 'raises invalid record error' do
        expect do
          subject.call(account, text: 'Hi future!', scheduled_at: invalid_scheduled_time)
        end.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Scheduled at date must be in the future'
        )
      end
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

  it 'raises on an invalid visibility' do
    expect do
      create_status_with_options(visibility: :xxx)
    end.to raise_error(
      ActiveRecord::RecordInvalid,
      'Validation failed: Visibility is not included in the list'
    )
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

  it 'creates a status with the quote approval policy set' do
    status = create_status_with_options(quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:followers] << 16)

    expect(status.quote_approval_policy).to eq(InteractionPolicy::POLICY_FLAGS[:followers] << 16)
  end

  it 'processes mentions' do
    mention_service = instance_double(ProcessMentionsService)
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
    end.to raise_error(an_instance_of(described_class::UnexpectedMentionsError).and(having_attributes(accounts: [unexpected_mentioned_account])))
  end

  it 'processes duplicate mentions correctly' do
    account = Fabricate(:account)
    Fabricate(:account, username: 'alice')

    expect do
      subject.call(account, text: '@alice @alice @alice hey @alice')
    end.to_not raise_error
  end

  it 'processes hashtags' do
    hashtags_service = instance_double(ProcessHashtagsService)
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
      media_ids: [media.id.to_s]
    )

    expect(media.reload.status).to eq status
  end

  it 'does not attach media from another account to the created status' do
    account = Fabricate(:account)
    media = Fabricate(:media_attachment, account: Fabricate(:account))

    expect do
      subject.call(
        account,
        text: 'test status update',
        media_ids: [media.id.to_s]
      )
    end.to raise_error(
      Mastodon::ValidationError,
      I18n.t('media_attachments.validations.not_found', ids: media.id)
    )
  end

  it 'does not allow attaching more files than configured limit' do
    stub_const('Status::MEDIA_ATTACHMENTS_LIMIT', 1)
    account = Fabricate(:account)

    expect do
      subject.call(
        account,
        text: 'test status update',
        media_ids: Array.new(2) { Fabricate(:media_attachment, account: account) }.map { |m| m.id.to_s }
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
        ].map { |m| m.id.to_s }
      )
    end.to raise_error(
      Mastodon::ValidationError,
      I18n.t('media_attachments.validations.images_and_video')
    )
  end

  it 'correctly requests a quote for remote posts' do
    account = Fabricate(:account)
    quoted_status = Fabricate(:status, account: Fabricate(:account, domain: 'example.com'))

    expect { subject.call(account, text: 'test', quoted_status: quoted_status) }
      .to enqueue_sidekiq_job(ActivityPub::QuoteRequestWorker)
  end

  it 'allows quotes with spoilers and no text' do
    account = Fabricate(:account)
    quoted_status = Fabricate(:status, account: Fabricate(:account, domain: 'example.com'))

    expect { subject.call(account, spoiler_text: 'test', quoted_status: quoted_status) }
      .to enqueue_sidekiq_job(ActivityPub::QuoteRequestWorker)
  end

  it 'correctly downgrades visibility for private self-quotes' do
    account = Fabricate(:account)
    quoted_status = Fabricate(:status, account: account, visibility: :private)

    status = subject.call(account, text: 'test', quoted_status: quoted_status)
    expect(status).to be_private_visibility
  end

  it 'correctly preserves visibility for private mentions self-quoting private posts' do
    account = Fabricate(:account)
    quoted_status = Fabricate(:status, account: account, visibility: :private)

    status = subject.call(account, text: 'test', quoted_status: quoted_status, visibility: 'direct')
    expect(status).to be_direct_visibility
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
