

Rails.application.configure do
  config.x.single_user_mode = ENV['SINGLE_USER_MODE'] == 'true'
end
