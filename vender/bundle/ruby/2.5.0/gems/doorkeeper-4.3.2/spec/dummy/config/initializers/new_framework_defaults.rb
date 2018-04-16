# Require `belongs_to` associations by default. This is a new Rails 5.0
# default, so it is introduced as a configuration option to ensure that apps
# made on earlier versions of Rails are not affected when upgrading.
if Rails::VERSION::MAJOR >= 5
  Rails.application.config.active_record.belongs_to_required_by_default = true
end
