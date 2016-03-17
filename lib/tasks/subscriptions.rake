namespace :subscriptions do

  desc "For all remote accounts that have no local followers, unsubscribe from PuSH"
  task clear: :environment do
    accounts = Account.where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) = 0').where.not(domain: nil)

    accounts.each do |a|
      a.subscription(api_subscription_url(a.id)).unsubscribe
      a.update!(verify_token: '', secret: '')
    end
  end

end
