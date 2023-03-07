# frozen_string_literal: true

GC.disable

if ENV['DISABLE_SIMPLECOV'] != 'true'
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_group 'Policies', 'app/policies'
    add_group 'Presenters', 'app/presenters'
    add_group 'Serializers', 'app/serializers'
    add_group 'Services', 'app/services'
    add_group 'Validators', 'app/validators'
  end
end

gc_counter = -1

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
  end

  config.after :suite do
    gc_counter = 0
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end

  config.after :each do
    gc_counter += 1

    if gc_counter > 19
      GC.enable
      GC.start
      GC.disable

      gc_counter = 0
    end
  end
end

def body_as_json
  json_str_to_hash(response.body)
end

def json_str_to_hash(str)
  JSON.parse(str, symbolize_names: true)
end

def expect_push_bulk_to_match(klass, matcher)
  expect(Sidekiq::Client).to receive(:push_bulk).with(hash_including({
    'class' => klass,
    'args' => matcher,
  }))
end
