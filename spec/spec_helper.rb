# frozen_string_literal: true

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'tmp/rspec/examples.txt'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true

    config.around(:example, :without_verify_partial_doubles) do |example|
      mocks.verify_partial_doubles = false
      example.call
      mocks.verify_partial_doubles = true
    end
  end

  config.before :suite do
    Rails.application.load_seed
    Chewy.strategy(:bypass)

    # NOTE: we switched registrations mode to closed by default, but the specs
    # very heavily rely on having it enabled by default, as it relies on users
    # being approved by default except in select cases where explicitly testing
    # other registration modes
    Setting.registrations_mode = 'open'
  end

  config.after :suite do
    FileUtils.rm_rf(Dir[Rails.root.join('spec', 'test_files')])
  end

  # Use the GitHub Annotations formatter for CI
  if ENV['GITHUB_ACTIONS'] == 'true' && ENV['GITHUB_RSPEC'] == 'true'
    require 'rspec/github'
    config.add_formatter RSpec::Github::Formatter
  end
end

def body_as_json
  json_str_to_hash(response.body)
end

def json_str_to_hash(str)
  JSON.parse(str, symbolize_names: true)
end

def serialized_record_json(record, serializer, adapter: nil)
  options = { serializer: serializer }
  options[:adapter] = adapter if adapter.present?
  JSON.parse(
    ActiveModelSerializers::SerializableResource.new(
      record,
      options
    ).to_json
  )
end

def expect_push_bulk_to_match(klass, matcher)
  allow(Sidekiq::Client).to receive(:push_bulk)
  yield
  expect(Sidekiq::Client).to have_received(:push_bulk).with(hash_including({
    'class' => klass,
    'args' => matcher,
  }))
end
