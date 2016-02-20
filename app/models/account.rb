class Account < ActiveRecord::Base
  has_many :statuses, inverse_of: :account

  def subscription(webhook_url)
    @subscription ||= OStatus2::Subscription.new(self.remote_url, secret: self.secret, token: self.verify_token, webhook: webhook_url, hub: self.hub_url)
  end
end
