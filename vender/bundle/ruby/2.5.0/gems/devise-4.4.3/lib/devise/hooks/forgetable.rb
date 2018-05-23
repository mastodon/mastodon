# frozen_string_literal: true

# Before logout hook to forget the user in the given scope, if it responds
# to forget_me! Also clear remember token to ensure the user won't be
# remembered again. Notice that we forget the user unless the record is not persisted.
# This avoids forgetting deleted users.
Warden::Manager.before_logout do |record, warden, options|
  if record.respond_to?(:forget_me!)
    Devise::Hooks::Proxy.new(warden).forget_me(record)
  end
end
