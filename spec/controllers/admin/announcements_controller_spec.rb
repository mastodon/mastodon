require 'rails_helper'

RSpec.describe Admin::AnnouncementsController, type: :controller do
  let(:user) { Fabricate(:user, admin: true) }

  before do
    sign_in user, scope: :user
  end

  describe 'PUT #update' do
    let(:announcement) { Fabricate(:announcement) }
    before do
      Fabricate.times(2, :announcement_link, announcement: announcement)
    end

    it do
      expect(announcement.links.length).to eq 2
    end

    it do
      links = announcement.links.each_with_index.map do |link, i|
        [i, {id: link.id, text: 'link', url: 'https://google.com' }]
      end.to_h
      put :update, params: { id: announcement.id, announcement: { body: 'hoge', links_attributes: links }}
      expect(announcement.reload.links.length).to eq 2
    end

    it do
      links = announcement.links.each_with_index.map do |link, i|
        [i, { id: link.id, text: '', url: '' }]
      end.to_h
      put :update, params: { id: announcement.id, announcement: { body: 'hoge', links_attributes: links } }
      expect(announcement.reload.links.length).to eq 0
    end
  end
end
