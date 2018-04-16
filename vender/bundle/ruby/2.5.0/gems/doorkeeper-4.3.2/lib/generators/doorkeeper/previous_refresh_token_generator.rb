require 'rails/generators/active_record'

class Doorkeeper::PreviousRefreshTokenGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc 'Support revoke refresh token on access token use'

  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end

  def previous_refresh_token
    if no_previous_refresh_token_column?
      migration_template(
        'add_previous_refresh_token_to_access_tokens.rb.erb',
        'db/migrate/add_previous_refresh_token_to_access_tokens.rb'
      )
    end
  end

  private

  def migration_version
    if ActiveRecord::VERSION::MAJOR >= 5
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
    end
  end

  def no_previous_refresh_token_column?
    !ActiveRecord::Base.connection.column_exists?(
      :oauth_access_tokens,
      :previous_refresh_token
    )
  end
end
