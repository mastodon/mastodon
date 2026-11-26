# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::ServerCheckSerializer do
  subject do
    serialized_record_json(
      record,
      described_class,
      options: { scope: current_user, scope_name: :current_user }
    )
  end

  let(:role) { Fabricate(:user_role, permissions_as_keys: [:administrator]) }
  let(:current_user) { Fabricate(:user, role:) }

  let(:record) { Fabricate('Admin::ServerCheck', key: 'rules', status: 'pending') }

  it 'includes key attribute' do
    expect(subject).to include('key' => record.key)
  end

  it 'includes status attribute' do
    expect(subject).to include('status' => record.status)
  end

  it 'includes ignored attribute' do
    expect(subject).to include('ignored' => record.ignored)
  end

  it 'includes severity attribute' do
    expect(subject).to include('severity' => record.severity)
  end

  it 'includes category attribute' do
    expect(subject).to include('category' => record.category)
  end

  it 'includes checked_at attribute' do
    expect(subject).to include('checked_at' => match_api_datetime_format)
  end

  it 'includes a translated title' do
    expect(subject).to include('title' => be_a(String))
  end

  it 'includes a translated explanation' do
    expect(subject).to include('explanation' => be_a(String))
  end

  it 'includes a setup_url' do
    expect(subject).to include('setup_url' => be_a(String))
  end
end
