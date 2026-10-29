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
  end
end
