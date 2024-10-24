# frozen_string_literal: true

if ENV['TEST_ENV_NUMBER'].present?
  starter = [ENV['TEST_ENV_NUMBER'].to_i * 1_000_000, 1].max
  ActiveRecord::Base.connection.execute <<~SQL.squish
    ALTER SEQUENCE backups_id_seq RESTART WITH #{starter}
  SQL
end
