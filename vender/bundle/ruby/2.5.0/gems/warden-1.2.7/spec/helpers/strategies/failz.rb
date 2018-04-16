# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:failz) do
  def authenticate!
    request.env['warden.spec.strategies'] ||= []
    request.env['warden.spec.strategies'] << :failz
    fail!("The Fails Strategy Has Failed You")
  end
end
