# frozen_string_literal: true

if defined? JRUBY_VERSION
  require "rake/javaextensiontask"
  Rake::JavaExtensionTask.new("nio4r_ext") do |ext|
    ext.ext_dir = "ext/nio4r"
  end
else
  require "rake/extensiontask"
  Rake::ExtensionTask.new("nio4r_ext") do |ext|
    ext.ext_dir = "ext/nio4r"
  end
end
