require 'sinatra'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  get '/' do
    'GET'
  end

  post '/' do
    'POST'
  end

  delete '/' do
    'DELETE'
  end
end

run App
