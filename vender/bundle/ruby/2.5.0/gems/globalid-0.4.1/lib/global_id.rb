require 'global_id/global_id'
require 'active_support'

autoload :SignedGlobalID, 'global_id/signed_global_id'

class GlobalID
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Locator
    autoload :Identification
    autoload :Verifier
  end

  def self.eager_load!
    super
    require 'global_id/signed_global_id'
  end
end
