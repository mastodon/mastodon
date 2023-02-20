Fabricator(:status) do
  account
  text 'Lorem ipsum dolor sit amet'

  after_build do |status|
    status.uri = Faker::Internet.device_token if !status.account.local? && status.uri.nil?
  end
end
