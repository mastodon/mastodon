node(:event) { 'notification' }

child :payload => :payload do
  extends 'api/v1/notifications/show'
end
