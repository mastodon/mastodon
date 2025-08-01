# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusesHelper do
  describe 'visibility_icon' do
    context 'with a status that is public' do
      let(:status) { Status.new(visibility: 'public') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('globe')
      end
    end

    context 'with a status that is unlisted' do
      let(:status) { Status.new(visibility: 'unlisted') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock_open')
      end
    end

    context 'with a status that is private' do
      let(:status) { Status.new(visibility: 'private') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock')
      end
    end

    context 'with a status that is direct' do
      let(:status) { Status.new(visibility: 'direct') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('alternate_email')
      end
    end
  end
end
