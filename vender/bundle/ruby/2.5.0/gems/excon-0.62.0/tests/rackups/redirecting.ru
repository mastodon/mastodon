require 'sinatra'
require 'json'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  post('/first') do
    redirect "/second"
  end

  get('/second') do
    post_body = request.body.read
    if post_body == "" && request["CONTENT_LENGTH"].nil?
      "ok"
    else
      JSON.pretty_generate(request.env)
    end
  end
end

run App
