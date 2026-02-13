# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/emoji'

RSpec.describe Mastodon::CLI::Emoji do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#purge' do
    let(:action) { :purge }

    context 'with existing custom emoji' do
      before { Fabricate(:custom_emoji) }

      it 'reports a successful purge' do
        expect { subject }
          .to output_results('OK')
      end
    end

    context 'with --suspended-only and existing custom emoji on blocked servers' do
      let(:blocked_domain) { 'evil.com' }
      let(:blocked_subdomain) { 'subdomain.evil.org' }
      let(:blocked_domain_without_emoji) { 'blocked.com' }
      let(:silenced_domain) { 'silenced.com' }

      let(:options) { { suspended_only: true } }

      before do
        Fabricate(:custom_emoji)
        Fabricate(:custom_emoji, domain: blocked_domain)
        Fabricate(:custom_emoji, domain: blocked_subdomain)
        Fabricate(:custom_emoji, domain: silenced_domain)

        Fabricate(:domain_block, severity: :suspend, domain: blocked_domain)
        Fabricate(:domain_block, severity: :suspend, domain: 'evil.org')
        Fabricate(:domain_block, severity: :suspend, domain: blocked_domain_without_emoji)
        Fabricate(:domain_block, severity: :silence, domain: silenced_domain)
      end

      it 'reports a successful purge' do
        expect { subject }
          .to output_results('OK')
          .and change { CustomEmoji.by_domain_and_subdomains(blocked_domain).count }.to(0)
          .and change { CustomEmoji.by_domain_and_subdomains('evil.org').count }.to(0)
          .and not_change { CustomEmoji.by_domain_and_subdomains(silenced_domain).count }
          .and(not_change { CustomEmoji.local.count })
      end
    end
  end

  describe '#import' do
    context 'with existing custom emoji' do
      let(:import_path) { Rails.root.join('spec', 'fixtures', 'files', 'elite-assets.tar.gz') }
      let(:action) { :import }
      let(:arguments) { [import_path] }

      it 'reports about imported emoji' do
        expect { subject }
          .to output_results('Imported 1')
          .and change(CustomEmoji, :count).by(1)
      end
    end
  end

  describe '#export' do
    context 'with existing custom emoji' do
      before do
        FileUtils.rm_rf(export_path.dirname)
        FileUtils.mkdir_p(export_path.dirname)

        Fabricate(:custom_emoji)
      end

      after { FileUtils.rm_rf(export_path.dirname) }

      let(:export_path) { Rails.root.join('tmp', 'cli-tests', 'export.tar.gz') }
      let(:arguments) { [export_path.dirname.to_s] }
      let(:action) { :export }

      it 'reports about exported emoji' do
        expect { subject }
          .to output_results('Exported 1')
          .and change { File.exist?(export_path) }.from(false).to(true)
      end
    end
  end
end
