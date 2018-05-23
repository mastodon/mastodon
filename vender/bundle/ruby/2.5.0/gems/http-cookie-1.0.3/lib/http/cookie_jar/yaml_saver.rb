# :markup: markdown
require 'http/cookie_jar'
require 'psych' if !defined?(YAML) && RUBY_VERSION == "1.9.2"
require 'yaml'

# YAMLSaver saves and loads cookies in the YAML format.  It can load a
# YAML file saved by Mechanize, but the saving format is not
# compatible with older versions of Mechanize (< 2.7).
class HTTP::CookieJar::YAMLSaver < HTTP::CookieJar::AbstractSaver
  # :singleton-method: new
  # :call-seq:
  #   new(**options)
  #
  # There is no option keyword supported at the moment.

  ##

  def save(io, jar)
    YAML.dump(@session ? jar.to_a : jar.reject(&:session?), io)
  end

  def load(io, jar)
    begin
      data = YAML.load(io)
    rescue ArgumentError => e
      case e.message
      when %r{\Aundefined class/module Mechanize::}
        # backward compatibility with Mechanize::Cookie
        begin
          io.rewind # hopefully
          yaml = io.read
          # a gross hack
          yaml.gsub!(%r{^(    [^ ].*:) !ruby/object:Mechanize::Cookie$}, "\\1")
          data = YAML.load(yaml)
        rescue Errno::ESPIPE
          @logger.warn "could not rewind the stream for conversion" if @logger
        rescue ArgumentError
        end
      end
    end

    case data
    when Array
      data.each { |cookie|
        jar.add(cookie)
      }
    when Hash
      # backward compatibility with Mechanize::Cookie
      data.each { |domain, paths|
        paths.each { |path, names|
          names.each { |cookie_name, cookie_hash|
            if cookie_hash.respond_to?(:ivars)
              # YAML::Object of Syck
              cookie_hash = cookie_hash.ivars
            end
            cookie = HTTP::Cookie.new({}.tap { |hash|
                cookie_hash.each_pair { |key, value|
                  hash[key.to_sym] = value
                }
              })
            jar.add(cookie)
          }
        }
      }
    else
      @logger.warn "incompatible YAML cookie data discarded" if @logger
      return
    end
  end

  private

  def default_options
    {}
  end
end
