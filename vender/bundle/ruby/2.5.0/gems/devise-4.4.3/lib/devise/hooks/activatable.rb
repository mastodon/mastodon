# frozen_string_literal: true

# Deny user access whenever their account is not active yet.
# We need this as hook to validate the user activity on each request
# and in case the user is using other strategies beside Devise ones.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active_for_authentication?) && !record.active_for_authentication?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, scope: scope, message: record.inactive_message
  end
end
