# frozen_string_literal: true

module ProfileStories
  attr_reader :bob, :alice, :alice_bio

  def fill_in_auth_details(email, password)
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on I18n.t('auth.login')
  end

  def as_a_registered_user
    @bob = Fabricate(
      :user,
      email: email, password: password, confirmed_at: confirmed_at,
      account: Fabricate(:account, username: 'bob')
    )

    Web::Setting.where(user: bob).first_or_initialize(user: bob).update!(data: { introductionVersion: 2018_12_16_044202 }) if finished_onboarding
  end

  def as_a_logged_in_user
    as_a_registered_user
    visit new_user_session_path
    fill_in_auth_details(email, password)
  end

  def as_a_logged_in_admin
    # This is a bit awkward, but this avoids code duplication.
    as_a_logged_in_user
    bob.update!(role: UserRole.find_by!(name: 'Admin'))
  end

  def with_alice_as_local_user
    @alice_bio = '@alice and @bob are fictional characters commonly used as' \
                 'placeholder names in #cryptology, as well as #science and' \
                 'engineering 📖 literature. Not affiliated with @pepe.'

    @alice = Fabricate(
      :user,
      email: 'alice@example.com', password: password, confirmed_at: confirmed_at,
      account: Fabricate(:account, username: 'alice', note: @alice_bio)
    )
  end

  def confirmed_at
    @confirmed_at ||= Time.zone.now
  end

  def email
    @email ||= 'test@example.com'
  end

  def password
    @password ||= 'password'
  end

  def finished_onboarding
    @finished_onboarding || false
  end
end
