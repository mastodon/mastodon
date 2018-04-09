require 'rails_helper'

RSpec.describe ActivityPub::Activity::Flag do
  let(:sender)  { Fabricate(:account, domain: 'example.com') }
  let(:flagged) { Fabricate(:account) }
  let(:status)  { Fabricate(:status, account: flagged, uri: 'foobar') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: nil,
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
end
