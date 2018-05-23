require_relative './benchmarking_support'
require_relative './app'

# https://github.com/ruby-bench/ruby-bench-suite/blob/8ad567f7e43a044ae48c36833218423bb1e2bd9d/rails/benchmarks/actionpack_router.rb
class ApiAssertion
  include Benchmark::ActiveModelSerializers::TestMethods
  class BadRevisionError < StandardError; end

  def valid?
    caching = get_caching
    caching[:body].delete('meta')
    non_caching = get_non_caching
    non_caching[:body].delete('meta')
    assert_responses(caching, non_caching)
  rescue BadRevisionError => e
    msg = { error: e.message }
    STDERR.puts msg
    STDOUT.puts msg
    exit 1
  end

  def get_status(on_off = 'on'.freeze)
    get("/status/#{on_off}")
  end

  def clear
    get('/clear')
  end

  def get_caching(on_off = 'on'.freeze)
    get("/caching/#{on_off}")
  end

  def get_fragment_caching(on_off = 'on'.freeze)
    get("/fragment_caching/#{on_off}")
  end

  def get_non_caching(on_off = 'on'.freeze)
    get("/non_caching/#{on_off}")
  end

  def debug(msg = '')
    if block_given? && ENV['DEBUG'] =~ /\Atrue|on|0\z/i
      STDERR.puts yield
    else
      STDERR.puts msg
    end
  end

  private

  def assert_responses(caching, non_caching)
    assert_equal(caching[:code], 200, "Caching response failed: #{caching}")
    assert_equal(caching[:body], expected, "Caching response format failed: \n+ #{caching[:body]}\n- #{expected}")
    assert_equal(caching[:content_type], 'application/json; charset=utf-8', "Caching response content type  failed: \n+ #{caching[:content_type]}\n- application/json")
    assert_equal(non_caching[:code], 200, "Non caching response failed: #{non_caching}")
    assert_equal(non_caching[:body], expected, "Non Caching response format failed: \n+ #{non_caching[:body]}\n- #{expected}")
    assert_equal(non_caching[:content_type], 'application/json; charset=utf-8', "Non caching response content type  failed: \n+ #{non_caching[:content_type]}\n- application/json")
  end

  def get(url)
    response = request(:get, url)
    { code: response.status, body: JSON.load(response.body), content_type: response.content_type }
  end

  def expected
    @expected ||=
      {
        'primary_resource' => {
          'id' => 1337,
          'title' => 'New PrimaryResource',
          'body' =>  'Body',
          'virtual_attribute' => {
            'id' => 999,
            'name' => 'Free-Range Virtual Attribute'
          },
          'has_one_relationship' => {
            'id' => 42,
            'first_name' => 'Joao',
            'last_name' => 'Moura'
          },
          'has_many_relationships' => [
            {
              'id' => 1,
              'body' => 'ZOMG A HAS MANY RELATIONSHIP'
            }
          ]
        }
      }
  end

  def assert_equal(expected, actual, message)
    return true if expected == actual
    if ENV['FAIL_ASSERTION'] =~ /\Atrue|on|0\z/i # rubocop:disable Style/GuardClause
      fail BadRevisionError, message
    else
      STDERR.puts message unless ENV['SUMMARIZE']
    end
  end
end
assertion = ApiAssertion.new
assertion.valid?
assertion.debug { assertion.get_status }

time = 10
{
  'caching on: caching serializers: gc off' => { disable_gc: true, send: [:get_caching, 'on'] },
  'caching on: fragment caching serializers: gc off' => { disable_gc: true, send: [:get_fragment_caching, 'on'] },
  'caching on: non-caching serializers: gc off' => { disable_gc: true, send: [:get_non_caching, 'on'] },
  'caching off: caching serializers: gc off' => { disable_gc: true, send: [:get_caching, 'off'] },
  'caching off: fragment caching serializers: gc off' => { disable_gc: true, send: [:get_fragment_caching, 'off'] },
  'caching off: non-caching serializers: gc off' => { disable_gc: true, send: [:get_non_caching, 'off'] }
}.each do |label, options|
  assertion.clear
  Benchmark.ams(label, time: time, disable_gc: options[:disable_gc]) do
    assertion.send(*options[:send])
  end
  assertion.debug { assertion.get_status(options[:send][-1]) }
end
