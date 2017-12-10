# frozen_string_literal: true

require 'rails_helper'

describe FanOutPreviewCardOnWriteService, type: :service do
  context 'with direct visibility' do
    let(:preview_card) { Fabricate(:preview_card) }
    let(:status) { Fabricate(:status, visibility: :direct) }

    before { preview_card.statuses << status }

    it 'delivers to mentioned followers' do
      follower = Fabricate(:account, id: 1)
      Fabricate(:follow, account: follower, target_account: status.account)
      Fabricate(:user, account: follower, current_sign_in_at: Time.now)
      Fabricate(:mention, status: status, account: follower)
      Redis.current.set 'subscribed:timeline:1:preview_card', '1'

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:1:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end
  end

  context 'without direct visibility' do
    let(:preview_card) { Fabricate(:preview_card) }
    let(:status) { Fabricate(:status, visibility: [:public, :unlisted, :private].sample) }

    before { preview_card.statuses << status }

    it 'delivers to followers' do
      follower = Fabricate(:account, id: 1)
      Fabricate(:follow, account: follower, target_account: status.account)
      Fabricate(:user, account: follower, current_sign_in_at: Time.now)
      Redis.current.set 'subscribed:timeline:1:preview_card', '1'

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:1:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end

    it 'delivers to lists' do
      follower = Fabricate(:account)
      Fabricate(:follow, account: follower, target_account: status.account)
      list = Fabricate(:list, account: follower, id: 1)
      Fabricate(:list_account, list: list, account: status.account)
      Fabricate(:user, account: follower, current_sign_in_at: Time.now)
      Redis.current.set 'subscribed:timeline:list:1:preview_card', '1'

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:list:1:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end
  end

  context 'if the account is local' do
    it 'delivers to self' do
      account = Fabricate(:account, domain: nil, id: 1)
      status = Fabricate(:status, account: account)
      Fabricate(:preview_card, statuses: [status])
      Redis.current.set 'subscribed:timeline:1:preview_card', '1'

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:1:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end

    it 'delivers to local hashtag timeline' do
      account = Fabricate(:account, domain: nil)
      status = Fabricate(:status, account: account)
      Fabricate(:preview_card, statuses: [status])
      Fabricate(:tag, name: 'name', statuses: [status])

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:hashtag:name:local:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end

    it 'delivers to local public timeline' do
      account = Fabricate(:account, domain: nil)
      status = Fabricate(:status, account: account)
      Fabricate(:preview_card, statuses: [status])

      matched = 0
      expect(Redis.current).to receive(:publish) do |key, message|
        if key === 'timeline:public:local:preview_card'
          matched += 1
        end
      end.at_least :once

      FanOutPreviewCardOnWriteService.new.call status

      expect(matched).to eq 1
    end
  end

  it 'delivers to hashtag timeline' do
    account = Fabricate(:account)
    status = Fabricate(:status, account: account)
    Fabricate(:preview_card, statuses: [status])
    Fabricate(:tag, name: 'name', statuses: [status])

    matched = 0
    expect(Redis.current).to receive(:publish) do |key, message|
      if key === 'timeline:hashtag:name:preview_card'
        matched += 1
      end
    end.at_least :once

    FanOutPreviewCardOnWriteService.new.call status

    expect(matched).to eq 1
  end

  it 'delivers to public timeline' do
    account = Fabricate(:account)
    status = Fabricate(:status, account: account)
    Fabricate(:preview_card, statuses: [status])

    matched = 0
    expect(Redis.current).to receive(:publish) do |key, message|
      if key === 'timeline:public:preview_card'
        matched += 1
      end
    end.at_least :once

    FanOutPreviewCardOnWriteService.new.call status

    expect(matched).to eq 1
  end

  it 'delivers rendered preview card' do
    status = Fabricate(:status, id: 1)
    PreviewCard.create!(
      id: 1,
      created_at: '2000-01-01T00:00:00Z',
      updated_at: '2000-01-01T00:00:00Z',
      url: 'https://example.com/',
      statuses: [status]
    )

    expect(Redis.current).to receive(:publish) do |key, message|
      expect(message).to eq '{"event":"card","payload":{"id":1,"card":{"id":1,"url":"https://example.com/","title":"","description":"","image_file_name":null,"image_content_type":null,"image_file_size":null,"image_updated_at":null,"type":"link","html":"","author_name":"","author_url":"","provider_name":"","provider_url":"","width":0,"height":0,"created_at":"2000-01-01T00:00:00.000Z","updated_at":"2000-01-01T00:00:00.000Z","embed_url":""}}}'
    end.at_least :once

    FanOutPreviewCardOnWriteService.new.call status
  end
end
