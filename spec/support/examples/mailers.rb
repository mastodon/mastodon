# frozen_string_literal: true

RSpec.shared_examples 'localized subject' do |*args, **kwrest|
  it 'renders subject localized for the locale of the receiver' do
    locale = :de
    receiver.update!(locale: locale)
    expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: locale))
  end

  it 'renders subject localized for the default locale if the locale of the receiver is unavailable' do
    receiver.update!(locale: nil)
    expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: I18n.default_locale))
  end
end

RSpec::Matchers.define :have_thread_headers do
  match(notify_expectation_failures: true) do |mail|
    expect(mail)
      .to be_present
      .and(have_header('In-Reply-To', conversation_header_regex))
      .and(have_header('References', conversation_header_regex))
  end

  def conversation_header_regex = /<conversation-\d+.\d\d\d\d-\d\d-\d\d@cb6e6126.ngrok.io>/
end

RSpec::Matchers.define :have_standard_headers do |type|
  chain :for do |user|
    @user = user
  end

  match(notify_expectation_failures: true) do |mail|
    expect(mail)
      .to be_present
      .and(have_header('To', "#{@user.account.username} <#{@user.email}>"))
      .and(have_header('List-ID', "<#{type}.#{@user.account.username}.#{Rails.configuration.x.local_domain}>"))
      .and(have_header('List-Unsubscribe', %r{<https://#{Rails.configuration.x.local_domain}/unsubscribe\?token=.+>}))
      .and(have_header('List-Unsubscribe', /&type=#{type}/))
      .and(have_header('List-Unsubscribe-Post', 'List-Unsubscribe=One-Click'))
      .and(deliver_to("#{@user.account.username} <#{@user.email}>"))
      .and(deliver_from(Rails.configuration.action_mailer.default_options[:from]))
  end
end
