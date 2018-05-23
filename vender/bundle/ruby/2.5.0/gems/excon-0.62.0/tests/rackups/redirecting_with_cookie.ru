require 'sinatra'
require 'sinatra/cookies'
require 'json'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class App < Sinatra::Base
  helpers Sinatra::Cookies
  set :environment, :production
  enable :dump_errors

  get('/sets_cookie') do
    cookies[:chocolatechip] = "chunky"
    redirect "/requires_cookie"
  end

  get('/requires_cookie') do
    cookie = cookies[:chocolatechip]
    unless cookie.nil? || cookie != "chunky"
      "ok"
    else
      JSON.pretty_generate(headers)
    end
  end
  
  get('/sets_multi_cookie') do
    cookies[:chocolatechip] = "chunky"
    cookies[:thinmints] = "minty"
    redirect "/requires_cookie"
  end

  get('/requires_cookie') do
    if cookies[:chocolatechip] == "chunky" && cookies[:thinmints] == "minty" 
      "ok"
    else
      JSON.pretty_generate(headers)
    end
  end
end

run App
