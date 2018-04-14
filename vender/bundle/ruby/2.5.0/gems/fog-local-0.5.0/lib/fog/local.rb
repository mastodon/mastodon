require 'fog/core'
require 'fileutils'
require 'tempfile'
require File.expand_path('../local/version', __FILE__)

module Fog
  module Storage
    autoload :Local, File.expand_path('../storage/local', __FILE__)
  end

  module Local
    extend Fog::Provider

    service(:storage, 'Storage')
  end
end
