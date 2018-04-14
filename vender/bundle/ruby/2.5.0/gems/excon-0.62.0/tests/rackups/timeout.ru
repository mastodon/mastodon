require 'sinatra'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  get('/timeout') do
    sleep(2)
    ''
  end
end

run App
