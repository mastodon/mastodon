module VersionHelper
  def active_support_version
    ActiveSupport::VERSION::STRING
  end

  def ruby_version
    RUBY_VERSION
  end
end
