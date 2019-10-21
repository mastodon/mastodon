# frozen_string_literal: true

module TankerIdentity
  def self.create(user_id)
    Tanker::Identity.create_identity(ENV["TANKER_APP_ID"], ENV["TANKER_APP_SECRET"], user_id.to_s)
  end
end

