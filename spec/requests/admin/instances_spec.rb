# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Instances' do
  describe 'GET /admin/instances/:id' do
    before { sign_in Fabricate(:admin_user) }

    context 'with an unknown domain' do
      it 'returns http success' do
        get admin_instance_path(id: 'unknown.example')

        expect(response)
          .to have_http_status(200)
      end
    end

    context 'with an invalid domain' do
      it 'returns http success' do
        get admin_instance_path(id: ' ')

        expect(response)
          .to have_http_status(200)
      end
    end
  end
end
