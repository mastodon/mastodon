class User < ActiveRecord::Base
  def self.authenticate!(name, password)
    User.where(name: name, password: password).first
  end
end
