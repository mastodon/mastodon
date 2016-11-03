object @status
cache false

extends 'api/v1/statuses/_show'

child :reblog => :reblog do
  extends 'api/v1/statuses/_show'
end
