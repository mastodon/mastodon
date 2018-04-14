# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:invalid) do
  def valid?
    false
  end

  def authenticate!; end
end
