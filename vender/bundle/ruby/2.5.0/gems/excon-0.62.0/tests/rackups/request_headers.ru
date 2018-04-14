require 'sinatra'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  post '/' do
    h = ""
    env.each { |k,v| h << "#{$1.downcase}: #{v}\n" if k =~ /http_(.*)/i }
    h
  end
end

run App
