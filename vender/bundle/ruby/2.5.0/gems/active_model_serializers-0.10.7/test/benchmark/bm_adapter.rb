require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered
has_many_relationships = (0..60).map do |i|
  HasManyRelationship.new(id: i, body: 'ZOMG A HAS MANY RELATIONSHIP')
end
has_one_relationship = HasOneRelationship.new(
  id: 42,
  first_name: 'Joao',
  last_name: 'Moura'
)
primary_resource = PrimaryResource.new(
  id: 1337,
  title: 'New PrimaryResource',
  virtual_attribute: nil,
  body: 'Body',
  has_many_relationships: has_many_relationships,
  has_one_relationship: has_one_relationship
)
serializer = PrimaryResourceSerializer.new(primary_resource)

Benchmark.ams('attributes', time: time, disable_gc: disable_gc) do
  attributes = ActiveModelSerializers::Adapter::Attributes.new(serializer)
  attributes.as_json
end

Benchmark.ams('json_api', time: time, disable_gc: disable_gc) do
  json_api = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
  json_api.as_json
end

Benchmark.ams('json', time: time, disable_gc: disable_gc) do
  json = ActiveModelSerializers::Adapter::Json.new(serializer)
  json.as_json
end
