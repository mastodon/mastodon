# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:pass) do
  def authenticate!
    request.env['warden.spec.strategies'] ||= []
    request.env['warden.spec.strategies'] << :pass
    success!("Valid User") unless scope == :failz
  end
end
