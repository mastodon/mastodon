# encoding: utf-8
# frozen_string_literal: true
Warden::Strategies.add(:password) do
  def authenticate!
    request.env['warden.spec.strategies'] ||= []
    request.env['warden.spec.strategies'] << :password
    if params["password"] || params["username"]
      params["password"] == "sekrit" && params["username"] == "fred" ?
        success!("Authenticated User") : fail!("Username or password is incorrect")
    else
      pass
    end
  end
end
