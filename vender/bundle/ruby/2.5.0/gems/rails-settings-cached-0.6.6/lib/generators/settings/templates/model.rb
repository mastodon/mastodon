# RailsSettings Model
class <%= class_name %> < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  namespace Rails.env
end
