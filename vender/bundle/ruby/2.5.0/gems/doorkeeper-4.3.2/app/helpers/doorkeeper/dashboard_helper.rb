module Doorkeeper
  module DashboardHelper
    def doorkeeper_errors_for(object, method)
      if object.errors[method].present?
        output = object.errors[method].map do |msg|
          content_tag(:span, class: 'help-block') do
            msg.capitalize
          end
        end

        safe_join(output)
      end
    end

    def doorkeeper_submit_path(application)
      application.persisted? ? oauth_application_path(application) : oauth_applications_path
    end
  end
end
