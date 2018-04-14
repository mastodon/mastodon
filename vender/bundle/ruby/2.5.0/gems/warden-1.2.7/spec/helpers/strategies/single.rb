# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:single) do
  def authenticate!
    request.env['warden.spec.strategies'] ||= []
    request.env['warden.spec.strategies'] << :single
    success!("Valid User")
  end

  def store?
    false
  end
end
