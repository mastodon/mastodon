# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/media'

describe Mastodon::CLI::Media do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#remove' do
    context 'with --prune-profiles and --remove-headers' do
      let(:options) { { prune_profiles: true, remove_headers: true } }

      it 'warns about usage and exits' do
        expect { cli.invoke(:remove, [], options) }.to output(
          a_string_including('--prune-profiles and --remove-headers should not be specified simultaneously')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with --include-follows but not including --prune-profiles and --remove-headers' do
      let(:options) { { include_follows: true } }

      it 'warns about usage and exits' do
        expect { cli.invoke(:remove, [], options) }.to output(
          a_string_including('--include-follows can only be used with --prune-profiles or --remove-headers')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with a relevant account' do
      let!(:account) do
        Fabricate(:account, domain: 'example.com', updated_at: 1.month.ago, last_webfingered_at: 1.month.ago, avatar: attachment_fixture('attachment.jpg'), header: attachment_fixture('attachment.jpg'))
      end

      context 'with --prune-profiles' do
        let(:options) { { prune_profiles: true } }

        it 'removes account avatars' do
          expect { cli.invoke(:remove, [], options) }.to output(
            a_string_including('Visited 1')
          ).to_stdout

          expect(account.reload.avatar).to be_blank
        end
      end

      context 'with --remove-headers' do
        let(:options) { { remove_headers: true } }

        it 'removes account header' do
          expect { cli.invoke(:remove, [], options) }.to output(
            a_string_including('Visited 1')
          ).to_stdout

          expect(account.reload.header).to be_blank
        end
      end
    end

    context 'with a relevant media attachment' do
      let!(:media_attachment) { Fabricate(:media_attachment, remote_url: 'https://example.com/image.jpg', created_at: 1.month.ago) }

      context 'without options' do
        it 'removes account avatars' do
          expect { cli.invoke(:remove) }.to output(
            a_string_including('Removed 1')
          ).to_stdout

          expect(media_attachment.reload.file).to be_blank
          expect(media_attachment.reload.thumbnail).to be_blank
        end
      end
    end
  end
end
