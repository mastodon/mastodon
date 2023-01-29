# frozen_string_literal: true

module ProfileStories
  attr_reader :bob, :alice, :alice_bio

  def as_a_registered_user
    @bob = Fabricate(
      :user,
      email: email, password: password, confirmed_at: confirmed_at,
      account: Fabricate(:account, username: 'bob')
    )
  end

  def as_a_logged_in_user
    as_a_registered_user
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on I18n.t('auth.login')
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
end
