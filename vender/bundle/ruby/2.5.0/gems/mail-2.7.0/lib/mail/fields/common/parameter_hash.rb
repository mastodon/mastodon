# encoding: utf-8
# frozen_string_literal: true
module Mail

  # ParameterHash is an intelligent Hash that allows you to add
  # parameter values including the MIME extension paramaters that
  # have the name*0="blah", name*1="bleh" keys, and will just return
  # a single key called name="blahbleh" and do any required un-encoding
  # to make that happen
  # Parameters are defined in RFC2045, split keys are in RFC2231

  class ParameterHash < IndifferentHash

    include Mail::Utilities

    def [](key_name)
      key_pattern = Regexp.escape(key_name.to_s)
      pairs = []
      exact = nil
      each do |k,v|
        if k =~ /^#{key_pattern}(\*|$)/i
          if $1 == ASTERISK
            pairs << [k, v]
          else
            exact = k
          end
        end
      end
      if pairs.empty? # Just dealing with a single value pair
        super(exact || key_name)
      else # Dealing with a multiple value pair or a single encoded value pair
        string = pairs.sort { |a,b| a.first.to_s <=> b.first.to_s }.map { |v| v.last }.join('')
        if mt = string.match(/([\w\-]+)?'(\w\w)?'(.*)/)
          string = mt[3]
          encoding = mt[1]
        else
          encoding = nil
        end
        Mail::Encodings.param_decode(string, encoding)
      end
    end

    def encoded
      map.sort_by { |a| a.first.to_s }.map! do |key_name, value|
        unless value.ascii_only?
          value = Mail::Encodings.param_encode(value)
          key_name = "#{key_name}*"
        end
        %Q{#{key_name}=#{quote_token(value)}}
      end.join(";\r\n\s")
    end

    def decoded
      map.sort_by { |a| a.first.to_s }.map! do |key_name, value|
        %Q{#{key_name}=#{quote_token(value)}}
      end.join("; ")
    end
  end
end
