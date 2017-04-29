attribute :queued_at, :if => lambda { |event| event.queued_at }

node(:event) { 'update' }

child :payload => :payload do
  extends 'api/v1/statuses/show'
end
