require 'rubygems'
require 'rake'

require File.join(File.dirname(__FILE__), 'lib', 'addressable', 'version')

PKG_DISPLAY_NAME   = 'Addressable'
PKG_NAME           = PKG_DISPLAY_NAME.downcase
PKG_VERSION        = Addressable::VERSION::STRING
PKG_FILE_NAME      = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME       = "REL #{PKG_VERSION}"

PKG_SUMMARY        = "URI Implementation"
PKG_DESCRIPTION    = <<-TEXT
Addressable is a replacement for the URI implementation that is part of
Ruby's standard library. It more closely conforms to the relevant RFCs and
adds support for IRIs and URI templates.
TEXT

PKG_FILES = FileList[
    "lib/**/*", "spec/**/*", "vendor/**/*", "data/**/*",
    "tasks/**/*",
    "[A-Z]*", "Rakefile"
].exclude(/pkg/).exclude(/database\.yml/).
  exclude(/Gemfile\.lock/).exclude(/[_\.]git$/)

task :default => "spec"

WINDOWS = (RUBY_PLATFORM =~ /mswin|win32|mingw|bccwin|cygwin/) rescue false
SUDO = WINDOWS ? '' : ('sudo' unless ENV['SUDOLESS'])

Dir['tasks/**/*.rake'].each { |rake| load rake }
