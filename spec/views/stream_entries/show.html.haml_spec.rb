require 'rails_helper'
$LOAD_PATH << '../lib'
require 'tag_manager'

describe 'stream_entries/show.html.haml' do
  before do
    double(:api_oembed_url => '')
    double(:account_stream_entry_url => '')
    allow(view).to receive(:show_landing_strip?).and_return(true)
  end

  it 'has valid author h-card and basic data for a detailed_status' do
    alice  =  Fabricate(:account, username: 'alice', display_name: 'Alice')
    bob    =  Fabricate(:account, username: 'bob', display_name: 'Bob')
    status =  Fabricate(:status, account: alice, text: 'Hello World')
    reply  =  Fabricate(:status, account: bob, thread: status, text: 'Hello Alice')

    assign(:status, status)
    assign(:stream_entry, status.stream_entry)
    assign(:account, alice)
    assign(:type, status.stream_entry.activity_type.downcase)

    render

    mf2 = Microformats2.parse(rendered)

    expect(mf2.entry.name.to_s).to eq status.text
    expect(mf2.entry.url.to_s).not_to be_empty

    expect(mf2.entry.author.format.name.to_s).to eq alice.display_name
    expect(mf2.entry.author.format.url.to_s).not_to be_empty
  end

  it 'has valid h-cites for p-in-reply-to and p-comment' do
    alice   =  Fabricate(:account, username: 'alice', display_name: 'Alice')
    bob     =  Fabricate(:account, username: 'bob', display_name: 'Bob')
    carl    =  Fabricate(:account, username: 'carl', display_name: 'Carl')
    status  =  Fabricate(:status, account: alice, text: 'Hello World')
    reply   =  Fabricate(:status, account: bob, thread: status, text: 'Hello Alice')
    comment =  Fabricate(:status, account: carl, thread: reply, text: 'Hello Bob')

    assign(:status, reply)
    assign(:stream_entry, reply.stream_entry)
    assign(:account, alice)
    assign(:type, reply.stream_entry.activity_type.downcase)
    assign(:ancestors, reply.stream_entry.activity.ancestors(bob) )
    assign(:descendants, reply.stream_entry.activity.descendants(bob))

    render

    mf2 = Microformats2.parse(rendered)

    expect(mf2.entry.name.to_s).to eq reply.text
    expect(mf2.entry.url.to_s).not_to be_empty

    expect(mf2.entry.comment.format.url.to_s).not_to be_empty
    expect(mf2.entry.comment.format.author.format.name.to_s).to eq carl.display_name
    expect(mf2.entry.comment.format.author.format.url.to_s).not_to be_empty

    expect(mf2.entry.in_reply_to.format.url.to_s).not_to be_empty
    expect(mf2.entry.in_reply_to.format.author.format.name.to_s).to eq alice.display_name
    expect(mf2.entry.in_reply_to.format.author.format.url.to_s).not_to be_empty
  end

  it 'has valid opengraph tags' do
    alice   =  Fabricate(:account, username: 'alice', display_name: 'Alice')
    status  =  Fabricate(:status, account: alice, text: 'Hello World')

    assign(:status, status)
    assign(:stream_entry, status.stream_entry)
    assign(:account, alice)
    assign(:type, status.stream_entry.activity_type.downcase)

    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content='.+' property='og:title'>})
    expect(header_tags).to match(%r{<meta content='article' property='og:type'>})
    expect(header_tags).to match(%r{<meta content='.+' property='og:image'>})
    expect(header_tags).to match(%r{<meta content='http://.+' property='og:url'>})
  end
end
