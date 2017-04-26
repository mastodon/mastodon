if Rails.env.production?
  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_ID'].to_i
    c.project_key = ENV['AIRBRAKE_KEY']

    c.root_directory = Rails.root

    c.logger = Rails.logger

    c.environment = Rails.env

    c.ignore_environments = %w(test)

    c.blacklist_keys = [/password/i, /authorization/i]
  end
end
