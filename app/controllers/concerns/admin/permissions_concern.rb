# frozen_string_literal: true

module Admin::PermissionsConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_moderator_or_admin_permissions
  end

  private

  def require_moderator_or_admin_permissions
    # not using #authorize here, so #verify_authorized still makes sure more fine-grained rules are enforced down the line
    forbidden unless Admin::BasePolicy.new(current_account, :base).access?
  end
end
