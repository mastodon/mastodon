begin
  require 'yaml'
  require 'json'
  require 'open-uri'

  namespace :oembed do
    desc "Update the noembed_urls.yml file using the services api."
    task :update_noembed do
      # Details at http://api.embed.ly/docs/service
      json_uri = URI.parse("https://noembed.com/providers")
      yaml_path = File.join(File.dirname(__FILE__), "../oembed/providers/noembed_urls.yml")

      services = JSON.parse(json_uri.read)

      url_regexps = []
      services.each do |service|
        url_regexps += service['patterns'].map{|r| r.strip }
      end
      url_regexps.sort!

      YAML.dump(url_regexps, File.open(yaml_path, 'w'))
    end

    desc "Update the embedly_urls.yml file using the services api."
    task :update_embedly do
      # Details at http://api.embed.ly/docs/service
      json_uri = URI.parse("http://api.embed.ly/1/services")
      yaml_path = File.join(File.dirname(__FILE__), "../oembed/providers/embedly_urls.yml")

      services = JSON.parse(json_uri.read)

      url_regexps = []
      services.each do |service|
        url_regexps += service['regex'].map{|r| r.strip }
      end
      url_regexps.sort!

      YAML.dump(url_regexps, File.open(yaml_path, 'w'))
    end

    task :update_oohembed do
      raise "Unfortunately the oohembed has discontinued."
    end
  end
rescue LoadError
  puts "The oembed rake tasks require JSON. Install it with: gem install json"
end
