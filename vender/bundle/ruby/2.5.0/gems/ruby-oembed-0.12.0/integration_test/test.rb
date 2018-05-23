require 'rubygems'
require File.dirname(__FILE__) + '/../lib/oembed'
OEmbed::Providers.register_all()
OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::Embedly, OEmbed::Providers::OohEmbed)


passed = "passed"
passed = "failed"
File.open("test_urls.csv", "r") do |infile|
    while (line = infile.gets)
        begin
            res = OEmbed::Providers.raw(line, :format => :json)
            passed = "passed"
        rescue OEmbed::NotFound => e
            if e.message == "OEmbed::NotFound"
                puts "not a supported url: " + line
            else
                puts e.message
            end
            passed = "failed"
        rescue OEmbed::UnknownResponse => e
            puts "got a bad network response" + e.message
            passed = "failed"
        rescue Timeout::Error
            puts "timeout error"
            passed = "failed"
        end
        
        puts passed + ": " + line
    end
end
