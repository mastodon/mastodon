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
