object @status
cache @status

extends 'api/v1/statuses/_show'

child :reblog => :reblog do
  extends 'api/v1/statuses/_show'
end
