# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings profile page' do
  let(:user) { Fabricate :user }
  let(:account) { user.account }

  before do
    allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
    sign_in user
  end

  it 'Views and updates profile information' do
    visit settings_profile_path

    expect(page)
      .to have_private_cache_control

    fill_in display_name_field, with: 'New name'
    attach_file avatar_field, Rails.root.join('spec', 'fixtures', 'files', 'avatar.gif')

    expect { click_on submit_button }
      .to change { account.reload.display_name }.to('New name')
      .and(change { account.reload.avatar.instance.avatar_file_name }.from(nil).to(be_present))
    expect(ActivityPub::UpdateDistributionWorker)
      .to have_received(:perform_async).with(account.id)
  end

  def display_name_field
    I18n.t('simple_form.labels.defaults.display_name')
  end

  def avatar_field
    I18n.t('simple_form.labels.defaults.avatar')
  end
end
