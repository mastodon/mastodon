object @message

attributes :id, :created_at

node(:content)          { |message| Formatter.instance.format(message) }

child :account do
  extends 'api/v1/accounts/show'
end

child :private_recipient do
  extends 'api/v1/accounts/show'
end