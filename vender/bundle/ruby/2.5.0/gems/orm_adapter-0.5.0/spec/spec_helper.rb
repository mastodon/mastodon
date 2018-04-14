require 'rubygems'
require 'rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

['dm-core', 'dm-active_model','mongoid', 'active_record', 'mongo_mapper'].each do |orm|
  begin
    require orm
  rescue LoadError
    puts "#{orm} not available"
  end
end

require 'orm_adapter'
