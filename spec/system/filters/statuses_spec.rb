# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters Statuses' do
  describe 'Viewing statuses under a filter' do
    let(:filter) { Fabricate(:custom_filter, title: 'good filter') }

    context 'with the filter user signed in' do
      before { sign_in(filter.account.user) }

      it 'returns a page with the status filters' do
        visit filter_statuses_path(filter)

        expect(page)
          .to have_private_cache_control
          .and have_title(/good filter/)
      end
    end
  end
end
