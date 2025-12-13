# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Antispam do
  describe '#local_preflight_check!' do
    subject { described_class.new(status).local_preflight_check! }

    let(:status) { Fabricate :status }

    context 'when there is no spammy text registered' do
      it { is_expected.to be_nil }
    end

    context 'with spammy text' do
      before { redis.sadd 'antispam:spammy_texts', 'https://banned.example' }

      context 'when status matches' do
        let(:status) { Fabricate :status, text: 'I use https://banned.example urls in my text' }

        it 'raises error and reports' do
          expect { subject }
            .to raise_error(described_class::SilentlyDrop)
            .and change(spam_reports, :count).by(1)
        end

        context 'when report already exists' do
          before { Fabricate :report, account: Account.representative, target_account: status.account }

          it 'raises error and does not report' do
            expect { subject }
              .to raise_error(described_class::SilentlyDrop)
              .and not_change(spam_reports, :count)
          end
        end

        def spam_reports
          Account.representative.reports.where(target_account: status.account).spam
        end
      end

      context 'when status matches unicode variants' do
        let(:status) { Fabricate :status, text: 'I use https://𝐛𝐚𝐧𝐧𝐞𝐝.𝐞𝐱𝐚𝐦𝐩𝐥𝐞 urls in my text' }

        it 'raises error and reports' do
          expect { subject }
            .to raise_error(described_class::SilentlyDrop)
            .and change(spam_reports, :count).by(1)
        end

        context 'when report already exists' do
          before { Fabricate :report, account: Account.representative, target_account: status.account }

          it 'raises error and does not report' do
            expect { subject }
              .to raise_error(described_class::SilentlyDrop)
              .and not_change(spam_reports, :count)
          end
        end

        def spam_reports
          Account.representative.reports.where(target_account: status.account).spam
        end
      end

      context 'when status does not match' do
        it { is_expected.to be_nil }
      end
    end
  end
end
