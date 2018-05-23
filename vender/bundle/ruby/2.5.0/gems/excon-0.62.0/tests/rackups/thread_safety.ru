require 'sinatra'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  get('/id/:id/wait/:wait') do |id, wait|
    sleep(wait.to_i)
    id.to_s
  end
end

# get everything autoloaded, mainly for rbx
App.new

run App
