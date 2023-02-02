# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackupService, type: :service do
  subject(:service_call) { described_class.new.call(backup) }

  let!(:user)           { Fabricate(:user) }
  let!(:attachment)     { Fabricate(:media_attachment, account: user.account) }
  let!(:status)         { Fabricate(:status, account: user.account, text: 'Hello', visibility: :public, media_attachments: [attachment]) }
  let!(:private_status) { Fabricate(:status, account: user.account, text: 'secret', visibility: :private) }
  let!(:favourite)      { Fabricate(:favourite, account: user.account) }
  let!(:bookmark)       { Fabricate(:bookmark, account: user.account) }
  let!(:backup)         { Fabricate(:backup, user: user) }

  def read_zip_file(backup, filename)
    file = Paperclip.io_adapters.for(backup.dump)
    Zip::File.open(file) do |zipfile|
      entry = zipfile.glob(filename).first
      return entry.get_input_stream.read
    end
  end

  it 'marks the backup as processed' do
    expect { service_call }.to change(backup, :processed).from(false).to(true)
  end

  it 'exports outbox.json as expected' do
    service_call

    json = Oj.load(read_zip_file(backup, 'outbox.json'))
    expect(json['@context']).to_not be_nil
    expect(json['type']).to eq 'OrderedCollection'
    expect(json['totalItems']).to eq 2
    expect(json['orderedItems'][0]['@context']).to be_nil
    expect(json['orderedItems'][0]).to include({
      'type' => 'Create',
      'object' => include({
        'id' => ActivityPub::TagManager.instance.uri_for(status),
        'content' => '<p>Hello</p>',
      }),
    })
    expect(json['orderedItems'][1]).to include({
      'type' => 'Create',
      'object' => include({
        'id' => ActivityPub::TagManager.instance.uri_for(private_status),
        'content' => '<p>secret</p>',
      }),
    })
  end

  it 'exports likes.json as expected' do
    service_call

    json = Oj.load(read_zip_file(backup, 'likes.json'))
    expect(json['type']).to eq 'OrderedCollection'
    expect(json['orderedItems']).to eq [ActivityPub::TagManager.instance.uri_for(favourite.status)]
  end

  it 'exports bookmarks.json as expected' do
    service_call

    json = Oj.load(read_zip_file(backup, 'bookmarks.json'))
    expect(json['type']).to eq 'OrderedCollection'
    expect(json['orderedItems']).to eq [ActivityPub::TagManager.instance.uri_for(bookmark.status)]
  end
end
