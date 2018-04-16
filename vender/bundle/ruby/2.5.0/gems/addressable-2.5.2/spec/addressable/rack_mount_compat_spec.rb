# coding: utf-8
# Copyright (C) Bob Aman
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


require "spec_helper"

require "addressable/uri"
require "addressable/template"
require "rack/mount"

describe Rack::Mount do
  let(:app_one) do
    proc { |env| [200, {'Content-Type' => 'text/plain'}, 'Route 1'] }
  end
  let(:app_two) do
    proc { |env| [200, {'Content-Type' => 'text/plain'}, 'Route 2'] }
  end
  let(:app_three) do
    proc { |env| [200, {'Content-Type' => 'text/plain'}, 'Route 3'] }
  end
  let(:routes) do
    s = Rack::Mount::RouteSet.new do |set|
      set.add_route(app_one, {
        :request_method => 'GET',
        :path_info => Addressable::Template.new('/one/{id}/')
      }, {:id => 'unidentified'}, :one)
      set.add_route(app_two, {
        :request_method => 'GET',
        :path_info => Addressable::Template.new('/two/')
      }, {:id => 'unidentified'}, :two)
      set.add_route(app_three, {
        :request_method => 'GET',
        :path_info => Addressable::Template.new('/three/{id}/').to_regexp
      }, {:id => 'unidentified'}, :three)
    end
    s.rehash
    s
  end

  it "should generate from routes with Addressable::Template" do
    path, _ = routes.generate(:path_info, :one, {:id => '123'})
    expect(path).to eq '/one/123/'
  end

  it "should generate from routes with Addressable::Template using defaults" do
    path, _ = routes.generate(:path_info, :one, {})
    expect(path).to eq '/one/unidentified/'
  end

  it "should recognize routes with Addressable::Template" do
    request = Rack::Request.new(
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/one/123/'
    )
    route, _, params = routes.recognize(request)
    expect(route).not_to be_nil
    expect(route.app).to eq app_one
    expect(params).to eq({id: '123'})
  end

  it "should generate from routes with Addressable::Template" do
    path, _ = routes.generate(:path_info, :two, {:id => '654'})
    expect(path).to eq '/two/'
  end

  it "should generate from routes with Addressable::Template using defaults" do
    path, _ = routes.generate(:path_info, :two, {})
    expect(path).to eq '/two/'
  end

  it "should recognize routes with Addressable::Template" do
    request = Rack::Request.new(
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/two/'
    )
    route, _, params = routes.recognize(request)
    expect(route).not_to be_nil
    expect(route.app).to eq app_two
    expect(params).to eq({id: 'unidentified'})
  end

  it "should recognize routes with derived Regexp" do
    request = Rack::Request.new(
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/three/789/'
    )
    route, _, params = routes.recognize(request)
    expect(route).not_to be_nil
    expect(route.app).to eq app_three
    expect(params).to eq({id: '789'})
  end
end
