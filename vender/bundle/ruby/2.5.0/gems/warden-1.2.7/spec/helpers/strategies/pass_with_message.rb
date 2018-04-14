# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:pass_with_message) do
  def authenticate!
    request.env['warden.spec.strategies'] ||= []
    request.env['warden.spec.strategies'] << :pass_with_message
    success!("Valid User", "The Success Strategy Has Accepted You") unless scope == :failz
  end
end
