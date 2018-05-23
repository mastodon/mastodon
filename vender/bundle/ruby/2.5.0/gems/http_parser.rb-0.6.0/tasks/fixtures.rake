desc "Generate test fixtures"
task :fixtures => :submodules do
  require 'yajl'
  data = File.read File.expand_path('../../ext/ruby_http_parser/vendor/http-parser/test.c', __FILE__)

  %w[ requests responses ].each do |type|
    # find test definitions in between requests/responses[]= and .name=NULL
    tmp = data[/#{type}\[\]\s*=(.+?),\s*\{\s*\.name=\s*NULL/m, 1]

    # replace first { with a [ (parsing an array of test cases)
    tmp.sub!('{','[')

    # replace booleans
    tmp.gsub!('TRUE', 'true')
    tmp.gsub!('FALSE', 'false')

    # mark strict mode tests
    tmp.gsub!(%r|#if\s+!HTTP_PARSER_STRICT(.+?)#endif\s*/\*\s*!HTTP_PARSER_STRICT.+\n|m){
      $1.gsub(/^(.+,\.type= .+)$/, "\\1\n,  .strict= false")
    }

    # remove macros and comments
    tmp.gsub!(/^#(if|elif|endif|define).+$/,'')
    tmp.gsub!(/\/\*(.+?)\*\/$/,'')

    # HTTP_* enums become strings
    tmp.gsub!(/(= )(HTTP_\w+)/){
      "#{$1}#{$2.sub('MSEARCH','M-SEARCH').dump}"
    }

    # join multiline strings for body and raw data
    tmp.gsub!(/((body|raw)\s*=)(.+?)(\n\s+[\},])/m){
      before, after = $1, $4
      raw = $3.split("\n").map{ |l| l.strip[1..-2] }.join('')
      "#{before} \"#{raw}\" #{after}"
    }

    # make headers an array of array tuples
    tmp.gsub!(/(\.headers\s*=)(.+?)(\s*,\.)/m){
      before, after = $1, $3
      raw = $2.gsub('{', '[').gsub('}', ']')
      "#{before} #{raw} #{after}"
    }

    # .name= becomes "name":
    tmp.gsub!(/^(.{2,5})\.(\w+)\s*=/){
      "#{$1}#{$2.dump}: "
    }

    # evaluate addition expressions
    tmp.gsub!(/(body_size\":\s*)(\d+)\+(\d+)/){
      "#{$1}#{$2.to_i+$3.to_i}"
    }

    # end result array
    tmp << ']'

    # normalize data
    results = Yajl.load(tmp, :symbolize_keys => true)
    results.map{ |res|
      res[:headers] and res[:headers] = Hash[*res[:headers].flatten]
      res[:method]  and res[:method].gsub!(/^HTTP_/, '')
      res[:strict] = true unless res.has_key?(:strict)
    }

    # write to a file
    File.open("spec/support/#{type}.json", 'w'){ |f|
      f.write Yajl.dump(results, :pretty => true)
    }
  end
end
