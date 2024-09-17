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

RSpec.shared_examples 'timestamp in time zone' do |at|
  it 'displays timestamp in time zone of the receiver' do
    time_zone = 'Europe/Berlin'
    receiver.update!(time_zone: time_zone)
    expect(mail)
      .to have_body_text(at.in_time_zone(time_zone).strftime(I18n.t('time.formats.with_time_zone')))
  end

  it 'displays timestamp in default time zone if the time zone of the receiver is unavailable' do
    allow(Rails.configuration.x).to receive(:default_time_zone).and_return('Europe/Athens')
    receiver.update!(time_zone: nil)

    expect(mail).to have_body_text(at.in_time_zone('Europe/Athens').strftime(I18n.t('time.formats.with_time_zone')))
  end
end
