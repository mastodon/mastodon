# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'JSON time serialization format' do # rubocop:disable RSpec/DescribeClass
  # Verify that Time and TimeWithZone objects always serialize to desired ISO 8601 format.
  #
  # This guards against a formatting difference when switching from the `oj` gem to
  # the stdlib `json` gem which can change the time format from:
  #   "2024-01-15T12:00:00.000Z"  (ISO 8601 / RFC 3339)
  # to
  #   "2024-01-15 12:00:00 UTC"   (Ruby's default to_s)
  #
  # See: config/initializers/json_time_format.rb

  let(:now) { Time.utc(2024, 1, 15, 12, 0, 0) }
  let(:time_with_zone) { ActiveSupport::TimeWithZone.new(now, ActiveSupport::TimeZone['UTC']) }

  describe 'Time#to_json' do
    it 'produces ISO 8601 format' do
      expect(now.to_json).to eq('"2024-01-15T12:00:00.000Z"')
    end
  end

  describe 'ActiveSupport::TimeWithZone#to_json' do
    it 'produces ISO 8601 format' do
      expect(time_with_zone.to_json).to eq('"2024-01-15T12:00:00.000Z"')
    end
  end

  describe 'JSON#generate' do
    it 'serializes Time inside a hash in ISO 8601 format' do
      json = JSON.generate(foo: now)
      parsed = JSON.parse(json)
      expect(parsed['foo']).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes Time inside an array in ISO 8601 format' do
      json = JSON.generate([now])
      parsed = JSON.parse(json)
      expect(parsed.first).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes TimeWithZone inside a hash in ISO 8601 format' do
      json = JSON.generate(foo: time_with_zone)
      parsed = JSON.parse(json)
      expect(parsed['foo']).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes TimeWithZone inside an array in ISO 8601 format' do
      json = JSON.generate([time_with_zone])
      parsed = JSON.parse(json)
      expect(parsed.first).to eq('2024-01-15T12:00:00.000Z')
    end
  end

  describe 'JSON#dump' do
    it 'serializes Time inside a hash in ISO 8601 format' do
      json = JSON.dump(foo: now)
      parsed = JSON.parse(json)
      expect(parsed['foo']).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes Time inside an array in ISO 8601 format' do
      json = JSON.dump([now])
      parsed = JSON.parse(json)
      expect(parsed.first).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes TimeWithZone inside a hash in ISO 8601 format' do
      json = JSON.dump(foo: time_with_zone)
      parsed = JSON.parse(json)
      expect(parsed['foo']).to eq('2024-01-15T12:00:00.000Z')
    end

    it 'serializes TimeWithZone inside an array in ISO 8601 format' do
      json = JSON.dump([time_with_zone])
      parsed = JSON.parse(json)
      expect(parsed.first).to eq('2024-01-15T12:00:00.000Z')
    end
  end

  describe 'serializer datetime format' do
    it 'preserves ISO 8601 format through ActiveModelSerializers as_json + JSON.generate' do
      marker = Fabricate.build(:marker, updated_at: now)
      serialized = ActiveModelSerializers::SerializableResource.new(
        marker,
        serializer: REST::MarkerSerializer
      ).as_json

      json_string = JSON.generate(serialized)
      parsed = JSON.parse(json_string)

      expect(parsed['updated_at']).to match_api_datetime_format
      expect(parsed['updated_at']).to eq('2024-01-15T12:00:00.000Z')
    end
  end
end
