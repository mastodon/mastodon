# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::StatusEditSerializer do
  subject do
    serialized_record_json(
      status_edit,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:status_edit) { Fabricate(:status_edit) }

  it 'does not contain a poll' do
    expect(subject).to_not include('poll')
  end

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format
        )
    end
  end

  context 'when poll_options is populated' do
    let(:status_edit) { Fabricate(:status_edit, poll_options: %w(Foo Bar)) }

    it 'renders the poll' do
      expect(subject)
        .to include(
          'poll' => include(
            'options' => contain_exactly(
              include('title' => 'Foo'),
              include('title' => 'Bar')
            )
          )
        )
    end
  end
end
