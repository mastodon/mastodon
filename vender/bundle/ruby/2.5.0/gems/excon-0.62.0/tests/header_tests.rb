Shindo.tests('Excon response header support') do
  env_init

  tests('Excon::Headers storage') do
    headers = Excon::Headers.new
    headers['Exact-Case'] = 'expected'
    headers['Another-Fixture'] = 'another'

    tests('stores and retrieves as received').returns('expected') do
      headers['Exact-Case']
    end

    tests('enumerates keys as received') do
      ks = headers.keys
      tests('contains Exact-Case').returns(true) { ks.include? 'Exact-Case' }
      tests('contains Another-Fixture').returns(true) { ks.include? 'Another-Fixture' }
    end

    tests('supports case-insensitive access').returns('expected') do
      headers['EXACT-CASE']
    end

    tests('but still returns nil for missing keys').returns(nil) do
      headers['Missing-Header']
    end

    tests('Hash methods that should support case-insensitive access') do
      if {}.respond_to? :assoc
        tests('#assoc').returns(%w{exact-case expected}) do
          headers.assoc('exact-Case')
        end
      end

      tests('#delete') do
        tests('with just a key').returns('yes') do
          headers['Extra'] = 'yes'
          headers.delete('extra')
        end

        tests('with a proc').returns('called with notpresent') do
          headers.delete('notpresent') { |k| "called with #{k}" }
        end
      end

      tests('#fetch') do
        tests('when present').returns('expected') { headers.fetch('exact-CASE') }
        tests('with a default value').returns('default') { headers.fetch('missing', 'default') }
        tests('with a default proc').returns('got missing') do
          headers.fetch('missing') { |k| "got #{k}" }
        end
      end

      tests('#has_key?') do
        tests('when present').returns(true) { headers.has_key?('EXACT-case') }
        tests('when absent').returns(false) { headers.has_key?('missing') }
      end

      tests('#values_at') do
        tests('all present').returns(%w{expected another}) do
          headers.values_at('exACT-cASE', 'anotheR-fixturE')
        end
        tests('some missing').returns(['expected', nil]) do
          headers.values_at('exact-case', 'missing-header')
        end
      end
    end
  end

  with_rackup('response_header.ru') do

    tests('Response#get_header') do
      connection = nil
      response = nil

      tests('with variable header capitalization') do

        tests('response.get_header("mixedcase-header")').returns('MixedCase') do
          connection = Excon.new('http://foo.com:8080', :proxy => 'http://127.0.0.1:9292')
          response = connection.request(:method => :get, :path => '/foo')

          response.get_header("mixedcase-header")
        end

        tests('response.get_header("uppercase-header")').returns('UPPERCASE') do
          response.get_header("uppercase-header")
        end

        tests('response.get_header("lowercase-header")').returns('lowercase') do
          response.get_header("lowercase-header")
        end

      end

      tests('when provided key capitalization varies') do

        tests('response.get_header("MIXEDCASE-HEADER")').returns('MixedCase') do
          response.get_header("MIXEDCASE-HEADER")
        end

        tests('response.get_header("MiXeDcAsE-hEaDeR")').returns('MixedCase') do
          response.get_header("MiXeDcAsE-hEaDeR")
        end

      end

      tests('when header is unavailable') do

        tests('response.get_header("missing")').returns(nil) do
          response.get_header("missing")
        end

      end

    end

  end

  env_restore
end
