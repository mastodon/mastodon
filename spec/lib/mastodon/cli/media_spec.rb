# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/media'

describe Mastodon::CLI::Media do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#remove' do
    let(:action) { :remove }

    context 'with --prune-profiles and --remove-headers' do
      let(:options) { { prune_profiles: true, remove_headers: true } }

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, '--prune-profiles and --remove-headers should not be specified simultaneously')
      end
    end

    context 'with --include-follows but not including --prune-profiles and --remove-headers' do
      let(:options) { { include_follows: true } }

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, '--include-follows can only be used with --prune-profiles or --remove-headers')
      end
    end

    context 'with a relevant account' do
      let!(:account) do
        Fabricate(:account, domain: 'example.com', updated_at: 1.month.ago, last_webfingered_at: 1.month.ago, avatar: attachment_fixture('attachment.jpg'), header: attachment_fixture('attachment.jpg'))
      end

      context 'with --prune-profiles' do
        let(:options) { { prune_profiles: true } }

        it 'removes account avatars' do
          expect { subject }
            .to output_results('Visited 1')

          expect(account.reload.avatar).to be_blank
        end
      end

      context 'with --remove-headers' do
        let(:options) { { remove_headers: true } }

        it 'removes account header' do
          expect { subject }
            .to output_results('Visited 1')

          expect(account.reload.header).to be_blank
        end
      end
    end

    context 'with a relevant media attachment' do
      let!(:media_attachment) { Fabricate(:media_attachment, remote_url: 'https://example.com/image.jpg', created_at: 1.month.ago) }

      context 'without options' do
        it 'removes account avatars' do
          expect { subject }
            .to output_results('Removed 1')

          expect(media_attachment.reload.file).to be_blank
          expect(media_attachment.reload.thumbnail).to be_blank
        end
      end
    end
  end

  describe '#usage' do
    let(:action) { :usage }

    context 'without options' do
      it 'reports about storage size' do
        expect { subject }
          .to output_results('0 Bytes')
      end
    end
  end

  describe '#lookup' do
    let(:action) { :lookup }
    let(:arguments) { [url] }

    context 'with valid url not connected to a record' do
      let(:url) { 'https://example.host/assets/1' }

      it 'warns about url and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'Not a media URL')
      end
    end

    context 'with a valid media url' do
      let(:status) { Fabricate(:status) }
      let(:media_attachment) { Fabricate(:media_attachment, status: status) }
      let(:url) { media_attachment.file.url(:original) }

      it 'displays the url of a connected status' do
        expect { subject }
          .to output_results(status.id.to_s)
      end
    end
  end

  describe '#refresh' do
    let(:action) { :refresh }

    context 'without any options' do
      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, /Specify the source/)
      end
    end

    context 'with --status option' do
      before do
        media_attachment.update(file_file_name: nil)
      end

      let(:media_attachment) { Fabricate(:media_attachment, status: status, remote_url: 'https://host.example/asset.jpg') }
      let(:options) { { status: status.id } }
      let(:status) { Fabricate(:status) }

      it 'redownloads the attachment file' do
        expect { subject }
          .to output_results('Downloaded 1 media')
      end
    end

    context 'with --account option' do
      context 'when the account does not exist' do
        let(:options) { { account: 'not-real-user@example.host' } }

        it 'warns about usage and exits' do
          expect { subject }
            .to raise_error(Thor::Error, 'No such account')
        end
      end

      context 'when the account exists' do
        before do
          media_attachment.update(file_file_name: nil)
        end

        let(:media_attachment) { Fabricate(:media_attachment, account: account) }
        let(:options) { { account: account.acct } }
        let(:account) { Fabricate(:account) }

        it 'redownloads the attachment file' do
          expect { subject }
            .to output_results('Downloaded 1 media')
        end
      end
    end

    context 'with --domain option' do
      before do
        media_attachment.update(file_file_name: nil)
      end

      let(:domain) { 'example.host' }
      let(:media_attachment) { Fabricate(:media_attachment, account: account) }
      let(:options) { { domain: domain } }
      let(:account) { Fabricate(:account, domain: domain) }

      it 'redownloads the attachment file' do
        expect { subject }
          .to output_results('Downloaded 1 media')
      end
    end

    context 'with --days option' do
      before do
        Fabricate(:media_attachment, remote_url: 'https://example.com/image.jpg', id: Mastodon::Snowflake.id_at(50.days.ago))
        Fabricate(:media_attachment, remote_url: 'https://example.com/image.jpg', id: Mastodon::Snowflake.id_at(5.days.ago))
        Fabricate(:media_attachment, remote_url: '', id: Mastodon::Snowflake.id_at(5.days.ago))
      end

      let(:options) { { days: 10 } }

      it 'redownloads the attachment file for the remote records more recent than the option' do
        expect { subject }
          .to output_results('Downloaded 1 media')
      end
    end
  end

  describe '#remove_orphans' do
    let(:action) { :remove_orphans }

    before do
      FileUtils.mkdir_p Rails.public_path.join('system')
    end

    context 'without any options' do
      it 'runs without error' do
        expect { subject }
          .to output_results('Removed', 'orphans (approx')
      end
    end

    context 'when in azure mode' do
      before do
        allow(Paperclip::Attachment).to receive(:default_options).and_return(storage: :azure)
      end

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, /azure storage driver is not supported/)
      end
    end

    context 'when in fog mode' do
      before do
        allow(Paperclip::Attachment).to receive(:default_options).and_return(storage: :fog)
      end

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, /fog storage driver is not supported/)
      end
    end

    context 'when in filesystem mode' do
      before do
        allow(File).to receive(:delete).and_return(true)
        media_attachment.delete
      end

      let(:media_attachment) { Fabricate(:media_attachment) }

      it 'removes the unlinked files' do
        expect { subject }
          .to output_results('Removed', 'orphans (approx')
        expect(File).to have_received(:delete).with(media_attachment.file.path)
      end
    end
  end
end
