require 'spec_helper_integration'
require 'generators/doorkeeper/previous_refresh_token_generator'

describe 'Doorkeeper::PreviousRefreshTokenGenerator' do
  include GeneratorSpec::TestCase

  tests Doorkeeper::PreviousRefreshTokenGenerator
  destination ::File.expand_path('../tmp/dummy', __FILE__)

  describe 'after running the generator' do
    before :each do
      prepare_destination

      allow_any_instance_of(Doorkeeper::PreviousRefreshTokenGenerator).to(
        receive(:no_previous_refresh_token_column?).and_return(true)
      )
    end

    context 'pre Rails 5.0.0' do
      it 'creates a migration with no version specifier' do
        stub_const('ActiveRecord::VERSION::MAJOR', 4)
        stub_const('ActiveRecord::VERSION::MINOR', 2)

        run_generator

        assert_migration 'db/migrate/add_previous_refresh_token_to_access_tokens.rb' do |migration|
          assert migration.include?("ActiveRecord::Migration\n")
        end
      end
    end

    context 'post Rails 5.0.0' do
      it 'creates a migration with a version specifier' do
        stub_const('ActiveRecord::VERSION::MAJOR', 5)
        stub_const('ActiveRecord::VERSION::MINOR', 0)

        run_generator

        assert_migration 'db/migrate/add_previous_refresh_token_to_access_tokens.rb' do |migration|
          assert migration.include?("ActiveRecord::Migration[5.0]\n")
        end
      end
    end

    context 'already exist' do
      it 'does not create a migration' do
        allow_any_instance_of(Doorkeeper::PreviousRefreshTokenGenerator).to(
          receive(:no_previous_refresh_token_column?).and_call_original
        )

        run_generator

        assert_no_migration 'db/migrate/add_previous_refresh_token_to_access_tokens.rb'
      end
    end
  end
end
