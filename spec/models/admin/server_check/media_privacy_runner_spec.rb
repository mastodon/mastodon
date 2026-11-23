# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::MediaPrivacyRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check runner available to devops users'

  describe '#run' do
    subject(:result) { runner.run }

    context 'when the media cannot be listed' do
      before do
        stub_request(:get, /#{Regexp.quote(Rails.configuration.x.local_domain)}/)
          .to_return(status: 200, body: 'a list of no files')
      end

      it { is_expected.to be_ok }
    end

    context 'when the media can be listed' do
      let(:dir) { 'http://localhost/files/' }
      let(:filename) { 'test.png' }
      let(:url) { "#{dir}#{filename}" }

      before do
        # rubocop:disable-next RSpec/AnyInstance
        allow_any_instance_of(Paperclip::Attachment).to receive(:url).and_return(url)
        stub_request(:get, dir).to_return(status: 200, body: filename)
      end

      it { is_expected.to be_pending }

      it 'adds a reason' do
        expect(result.data).to include(reason: :upload_check_privacy_error)
      end
    end

    context 'when using S3 with a custom endpoint' do
      around do |example|
        use_s3 = Rails.configuration.x.use_s3
        example.run
        Rails.configuration.x.use_s3 = use_s3
      end

      before do
        Rails.configuration.x.use_s3 = true
        allow(Paperclip::Attachment).to receive(:default_options).and_return(
          Paperclip::Attachment.default_options.merge(
            s3_protocol: 'https',
            s3_host_name: 's3-auto.amazonaws.com',
            s3_credentials: { bucket: 'mastodon' },
            s3_options: { endpoint: 'https://storage.example.com' }
          )
        )
        stub_request(:get, %r{\Ahttps://storage\.example\.com/mastodon/}).to_return(status: 200, body: '<ListBucketResult></ListBucketResult>')
      end

      it { is_expected.to be_pending }

      it 'adds a reason' do
        expect(result.data).to include(reason: :upload_check_privacy_error_object_storage)
      end
    end
  end
end
