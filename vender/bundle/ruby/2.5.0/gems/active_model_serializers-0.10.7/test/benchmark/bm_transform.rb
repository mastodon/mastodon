require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered
has_many_relationships = (0..50).map do |i|
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
adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
serialization = adapter.as_json

Benchmark.ams('camel', time: time, disable_gc: disable_gc) do
  CaseTransform.camel(serialization)
end

Benchmark.ams('camel_lower', time: time, disable_gc: disable_gc) do
  CaseTransform.camel_lower(serialization)
end

Benchmark.ams('dash', time: time, disable_gc: disable_gc) do
  CaseTransform.dash(serialization)
end

Benchmark.ams('unaltered', time: time, disable_gc: disable_gc) do
  CaseTransform.unaltered(serialization)
end

Benchmark.ams('underscore', time: time, disable_gc: disable_gc) do
  CaseTransform.underscore(serialization)
end
