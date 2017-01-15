module ApplicationExtension
  extend ActiveSupport::Concern
  included do
    validates :website
  end
end

Doorkeeper::Application.send :include, ApplicationExtension