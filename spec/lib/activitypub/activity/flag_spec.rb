require 'rails_helper'

RSpec.describe ActivityPub::Activity::Flag do
  let(:sender)  { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account') }
  let(:flagged) { Fabricate(:account) }
  let(:status)  { Fabricate(:status, account: flagged, uri: 'foobar') }
  let(:flag_id) { nil }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: flag_id,
      type: 'Flag',
      content: 'Boo!!',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: [
        ActivityPub::TagManager.instance.uri_for(flagged),
        ActivityPub::TagManager.instance.uri_for(status),
      ],
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    it 'creates a report' do
      report = Report.find_by(account: sender, target_account: flagged)

      expect(report).to_not be_nil
      expect(report.comment).to eq 'Boo!!'
      expect(report.status_ids).to eq [status.id]
    end
  end

  describe '#perform with a defined uri' do
    subject { described_class.new(json, sender) }
    let (:flag_id) { 'http://example.com/reports/1' }

    before do
      subject.perform
    end

    it 'creates a report' do
      report = Report.find_by(account: sender, target_account: flagged)

      expect(report).to_not be_nil
      expect(report.comment).to eq 'Boo!!'
      expect(report.status_ids).to eq [status.id]
      expect(report.uri).to eq flag_id
    end
  end
end
