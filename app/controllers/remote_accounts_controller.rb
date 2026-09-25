# frozen_string_literal: true

class RemoteAccountsController < HomeController
  before_action :require_resource_exists!

  private

  def require_resource_exists!
    # The page should still render normally, but the HTTP code should be modified
    response.status = 404 if PermalinkRedirector.new(request.original_fullpath).object.nil?
  end
end
