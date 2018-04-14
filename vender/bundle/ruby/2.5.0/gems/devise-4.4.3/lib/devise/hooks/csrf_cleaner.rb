# frozen_string_literal: true

Warden::Manager.after_authentication do |record, warden, options|
  clean_up_for_winning_strategy = !warden.winning_strategy.respond_to?(:clean_up_csrf?) ||
    warden.winning_strategy.clean_up_csrf?
  if Devise.clean_up_csrf_token_on_authentication && clean_up_for_winning_strategy
    warden.request.session.try(:delete, :_csrf_token)
  end
end
