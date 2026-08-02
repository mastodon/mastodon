# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Tags' do
  before { sign_in Fabricate(:admin_user) }

  describe 'PUT /admin/tags/:id' do
    let(:tag) { Fabricate :tag }

    it 'gracefully handles invalid nested params' do
      put admin_tag_path(tag.id, tag: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'update tag' do
    let(:tag) { Fabricate :tag, name: '#supertag' }

    it 'redirects to tag page and saves update log action for all attribute statuses' do
      put admin_tag_path(tag.id, params: { tag: { trendable: true, listable: false, unallowed: true } })

      expect(response).to have_http_status(302)
      expect(Admin::ActionLog.pluck(:recorded_changes)).to eq([{ 'listable' => false, 'trendable' => true }])
      expect(Admin::ActionLog.last.recorded_changes).to match_json_schema('tags_format_1.0')
    end

    it 'returns invalid when the schema does not match' do
      put admin_tag_path(tag.id, params: { tag: { trendable: true } })

      Admin::ActionLog.last.update(recorded_changes: { 'unallowed' => false })
      expect(Admin::ActionLog.last.recorded_changes).to_not match_json_schema('tags_format_1.0')
    end
  end
end
