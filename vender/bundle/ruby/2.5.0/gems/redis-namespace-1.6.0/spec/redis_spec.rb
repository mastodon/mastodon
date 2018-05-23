# encoding: utf-8

require File.dirname(__FILE__) + '/spec_helper'

describe "redis" do
  @redis_version = Gem::Version.new(Redis.current.info["redis_version"])
  let(:redis_client) { @redis.respond_to?(:_client) ? @redis._client : @redis.client}

  before(:all) do
    # use database 15 for testing so we dont accidentally step on your real data
    @redis = Redis.new :db => 15
  end

  before(:each) do
    @namespaced = Redis::Namespace.new(:ns, :redis => @redis)
    @redis.flushdb
    @redis.set('foo', 'bar')
  end

  after(:each) do
    @redis.flushdb
  end

  after(:all) do
    @redis.quit
  end

  it "proxies `client` to the _client and deprecated" do
    @namespaced.client.should eq(redis_client)
  end

  it "proxies `_client` to the _client" do
    @namespaced._client.should eq(redis_client)
  end

  it "should be able to use a namespace" do
    @namespaced.get('foo').should eq(nil)
    @namespaced.set('foo', 'chris')
    @namespaced.get('foo').should eq('chris')
    @redis.set('foo', 'bob')
    @redis.get('foo').should eq('bob')

    @namespaced.incrby('counter', 2)
    @namespaced.get('counter').to_i.should eq(2)
    @redis.get('counter').should eq(nil)
    @namespaced.type('counter').should eq('string')
  end

  context 'when sending capital commands (issue 68)' do
    it 'should be able to use a namespace' do
      @namespaced.send('SET', 'fubar', 'quux')
      @redis.get('fubar').should be_nil
      @namespaced.get('fubar').should eq 'quux'
    end
  end

  it "should be able to use a namespace with bpop" do
    @namespaced.rpush "foo", "string"
    @namespaced.rpush "foo", "ns:string"
    @namespaced.rpush "foo", "string_no_timeout"
    @namespaced.blpop("foo", 1).should eq(["foo", "string"])
    @namespaced.blpop("foo", 1).should eq(["foo", "ns:string"])
    @namespaced.blpop("foo").should eq(["foo", "string_no_timeout"])
    @namespaced.blpop("foo", 1).should eq(nil)
  end

  it "should be able to use a namespace with del" do
    @namespaced.set('foo', 1000)
    @namespaced.set('bar', 2000)
    @namespaced.set('baz', 3000)
    @namespaced.del 'foo'
    @namespaced.get('foo').should eq(nil)
    @namespaced.del 'bar', 'baz'
    @namespaced.get('bar').should eq(nil)
    @namespaced.get('baz').should eq(nil)
  end

  it 'should be able to use a namespace with append' do
    @namespaced.set('foo', 'bar')
    @namespaced.append('foo','n').should eq(4)
    @namespaced.get('foo').should eq('barn')
    @redis.get('foo').should eq('bar')
  end

  it 'should be able to use a namespace with brpoplpush' do
    @namespaced.lpush('foo','bar')
    @namespaced.brpoplpush('foo','bar',0).should eq('bar')
    @namespaced.lrange('foo',0,-1).should eq([])
    @namespaced.lrange('bar',0,-1).should eq(['bar'])
  end

  it 'should be able to use a namespace with getbit' do
    @namespaced.set('foo','bar')
    @namespaced.getbit('foo',1).should eq(1)
  end

  it 'should be able to use a namespace with getrange' do
    @namespaced.set('foo','bar')
    @namespaced.getrange('foo',0,-1).should eq('bar')
  end

  it 'should be able to use a namespace with linsert' do
    @namespaced.rpush('foo','bar')
    @namespaced.rpush('foo','barn')
    @namespaced.rpush('foo','bart')
    @namespaced.linsert('foo','BEFORE','barn','barf').should eq(4)
    @namespaced.lrange('foo',0,-1).should eq(['bar','barf','barn','bart'])
  end

  it 'should be able to use a namespace with lpushx' do
    @namespaced.lpushx('foo','bar').should eq(0)
    @namespaced.lpush('foo','boo')
    @namespaced.lpushx('foo','bar').should eq(2)
    @namespaced.lrange('foo',0,-1).should eq(['bar','boo'])
  end

  it 'should be able to use a namespace with rpushx' do
    @namespaced.rpushx('foo','bar').should eq(0)
    @namespaced.lpush('foo','boo')
    @namespaced.rpushx('foo','bar').should eq(2)
    @namespaced.lrange('foo',0,-1).should eq(['boo','bar'])
  end

  it 'should be able to use a namespace with setbit' do
    @namespaced.setbit('virgin_key', 1, 1)
    @namespaced.exists('virgin_key').should be_true
    @namespaced.get('virgin_key').should eq(@namespaced.getrange('virgin_key',0,-1))
  end

  it 'should be able to use a namespace with setrange' do
    @namespaced.setrange('foo', 0, 'bar')
    @namespaced.get('foo').should eq('bar')

    @namespaced.setrange('bar', 2, 'foo')
    @namespaced.get('bar').should eq("\000\000foo")
  end

  it "should be able to use a namespace with mget" do
    @namespaced.set('foo', 1000)
    @namespaced.set('bar', 2000)
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '1000', 'bar' => '2000' })
    @namespaced.mapped_mget('foo', 'baz', 'bar').should eq({'foo'=>'1000', 'bar'=>'2000', 'baz' => nil})
  end

  it "should be able to use a namespace with mset" do
    @namespaced.mset('foo', '1000', 'bar', '2000')
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '1000', 'bar' => '2000' })
    @namespaced.mapped_mget('foo', 'baz', 'bar').should eq({ 'foo' => '1000', 'bar' => '2000', 'baz' => nil})
    @namespaced.mapped_mset('foo' => '3000', 'bar' => '5000')
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '3000', 'bar' => '5000' })
    @namespaced.mapped_mget('foo', 'baz', 'bar').should eq({ 'foo' => '3000', 'bar' => '5000', 'baz' => nil})
  end

  it "should be able to use a namespace with msetnx" do
    @namespaced.msetnx('foo', '1000', 'bar', '2000')
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '1000', 'bar' => '2000' })
    @namespaced.mapped_mget('foo', 'baz', 'bar').should eq({ 'foo' => '1000', 'bar' => '2000', 'baz' => nil})
  end

  it "should be able to use a namespace with mapped_msetnx" do
    @namespaced.set('foo','1')
    @namespaced.mapped_msetnx('foo'=>'1000', 'bar'=>'2000').should be_false
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '1', 'bar' => nil })
    @namespaced.mapped_msetnx('bar'=>'2000', 'baz'=>'1000').should be_true
    @namespaced.mapped_mget('foo', 'bar').should eq({ 'foo' => '1', 'bar' => '2000' })
  end

  it "should be able to use a namespace with hashes" do
    @namespaced.hset('foo', 'key', 'value')
    @namespaced.hset('foo', 'key1', 'value1')
    @namespaced.hget('foo', 'key').should eq('value')
    @namespaced.hgetall('foo').should eq({'key' => 'value', 'key1' => 'value1'})
    @namespaced.hlen('foo').should eq(2)
    @namespaced.hkeys('foo').should eq(['key', 'key1'])
    @namespaced.hmset('bar', 'key', 'value', 'key1', 'value1')
    @namespaced.hmget('bar', 'key', 'key1')
    @namespaced.hmset('bar', 'a_number', 1)
    @namespaced.hmget('bar', 'a_number').should eq(['1'])
    @namespaced.hincrby('bar', 'a_number', 3)
    @namespaced.hmget('bar', 'a_number').should eq(['4'])
    @namespaced.hgetall('bar').should eq({'key' => 'value', 'key1' => 'value1', 'a_number' => '4'})

    @namespaced.hsetnx('foonx','nx',10).should be_true
    @namespaced.hsetnx('foonx','nx',12).should be_false
    @namespaced.hget('foonx','nx').should eq("10")
    @namespaced.hkeys('foonx').should eq(%w{ nx })
    @namespaced.hvals('foonx').should eq(%w{ 10 })
    @namespaced.mapped_hmset('baz', {'key' => 'value', 'key1' => 'value1', 'a_number' => 4})
    @namespaced.mapped_hmget('baz', 'key', 'key1', 'a_number').should eq({'key' => 'value', 'key1' => 'value1', 'a_number' => '4'})
    @namespaced.hgetall('baz').should eq({'key' => 'value', 'key1' => 'value1', 'a_number' => '4'})
  end

  it "should properly intersect three sets" do
    @namespaced.sadd('foo', 1)
    @namespaced.sadd('foo', 2)
    @namespaced.sadd('foo', 3)
    @namespaced.sadd('bar', 2)
    @namespaced.sadd('bar', 3)
    @namespaced.sadd('bar', 4)
    @namespaced.sadd('baz', 3)
    @namespaced.sinter('foo', 'bar', 'baz').should eq(%w( 3 ))
  end

  it "should properly union two sets" do
    @namespaced.sadd('foo', 1)
    @namespaced.sadd('foo', 2)
    @namespaced.sadd('bar', 2)
    @namespaced.sadd('bar', 3)
    @namespaced.sadd('bar', 4)
    @namespaced.sunion('foo', 'bar').sort.should eq(%w( 1 2 3 4 ))
  end

  it "should properly union two sorted sets with options" do
    @namespaced.zadd('sort1', 1, 1)
    @namespaced.zadd('sort1', 2, 2)
    @namespaced.zadd('sort2', 2, 2)
    @namespaced.zadd('sort2', 3, 3)
    @namespaced.zadd('sort2', 4, 4)
    @namespaced.zunionstore('union', ['sort1', 'sort2'], :weights => [2, 1])
    @namespaced.zrevrange('union', 0, -1).should eq(%w( 2 4 3 1 ))
  end

  it "should properly union two sorted sets without options" do
    @namespaced.zadd('sort1', 1, 1)
    @namespaced.zadd('sort1', 2, 2)
    @namespaced.zadd('sort2', 2, 2)
    @namespaced.zadd('sort2', 3, 3)
    @namespaced.zadd('sort2', 4, 4)
    @namespaced.zunionstore('union', ['sort1', 'sort2'])
    @namespaced.zrevrange('union', 0, -1).should eq(%w( 4 2 3 1 ))
  end

  it "should properly intersect two sorted sets without options" do
    @namespaced.zadd('food', 1, 'orange')
    @namespaced.zadd('food', 2, 'banana')
    @namespaced.zadd('food', 3, 'eggplant')

    @namespaced.zadd('color', 2, 'orange')
    @namespaced.zadd('color', 3, 'yellow')
    @namespaced.zadd('color', 4, 'eggplant')

    @namespaced.zinterstore('inter', ['food', 'color'])

    inter_values = @namespaced.zrevrange('inter', 0, -1, :with_scores => true)
    inter_values.should =~ [['orange', 3.0], ['eggplant', 7.0]]
  end

  it "should properly intersect two sorted sets with options" do
    @namespaced.zadd('food', 1, 'orange')
    @namespaced.zadd('food', 2, 'banana')
    @namespaced.zadd('food', 3, 'eggplant')

    @namespaced.zadd('color', 2, 'orange')
    @namespaced.zadd('color', 3, 'yellow')
    @namespaced.zadd('color', 4, 'eggplant')

    @namespaced.zinterstore('inter', ['food', 'color'], :aggregate => "min")

    inter_values = @namespaced.zrevrange('inter', 0, -1, :with_scores => true)
    inter_values.should =~ [['orange', 1.0], ['eggplant', 3.0]]
  end

  it "should add namespace to sort" do
    @namespaced.sadd('foo', 1)
    @namespaced.sadd('foo', 2)
    @namespaced.set('weight_1', 2)
    @namespaced.set('weight_2', 1)
    @namespaced.set('value_1', 'a')
    @namespaced.set('value_2', 'b')

    @namespaced.sort('foo').should eq(%w( 1 2 ))
    @namespaced.sort('foo', :limit => [0, 1]).should eq(%w( 1 ))
    @namespaced.sort('foo', :order => 'desc').should eq(%w( 2 1 ))
    @namespaced.sort('foo', :by => 'weight_*').should eq(%w( 2 1 ))
    @namespaced.sort('foo', :get => 'value_*').should eq(%w( a b ))
    @namespaced.sort('foo', :get => '#').should eq(%w( 1 2 ))
    @namespaced.sort('foo', :get => ['#', 'value_*']).should eq([["1", "a"], ["2", "b"]])

    @namespaced.sort('foo', :store => 'result')
    @namespaced.lrange('result', 0, -1).should eq(%w( 1 2 ))
  end

  it "should yield the correct list of keys" do
    @namespaced.set("foo", 1)
    @namespaced.set("bar", 2)
    @namespaced.set("baz", 3)
    @namespaced.keys("*").sort.should eq(%w( bar baz foo ))
    @namespaced.keys.sort.should eq(%w( bar baz foo ))
  end

  it "should add namepsace to multi blocks" do
    @namespaced.mapped_hmset "foo", {"key" => "value"}
    @namespaced.multi do |r|
      r.del "foo"
      r.mapped_hmset "foo", {"key1" => "value1"}
    end
    @namespaced.hgetall("foo").should eq({"key1" => "value1"})
  end

  it "should pass through multi commands without block" do
    @namespaced.mapped_hmset "foo", {"key" => "value"}

    @namespaced.multi
    @namespaced.del "foo"
    @namespaced.mapped_hmset "foo", {"key1" => "value1"}
    @namespaced.exec

    @namespaced.hgetall("foo").should eq({"key1" => "value1"})
  end

  it 'should return futures without attempting to remove namespaces' do
    @namespaced.multi do
      @future = @namespaced.keys('*')
    end
    @future.class.should be(Redis::Future)
  end

  it "should add namespace to pipelined blocks" do
    @namespaced.mapped_hmset "foo", {"key" => "value"}
    @namespaced.pipelined do |r|
      r.del "foo"
      r.mapped_hmset "foo", {"key1" => "value1"}
    end
    @namespaced.hgetall("foo").should eq({"key1" => "value1"})
  end

  it "should returned response array from pipelined block" do
    @namespaced.mset "foo", "bar", "key", "value"
    result = @namespaced.pipelined do |r|
      r.get("foo")
      r.get("key")
    end
    result.should eq(["bar", "value"])
  end

  it "should add namespace to strlen" do
    @namespaced.set("mykey", "123456")
    @namespaced.strlen("mykey").should eq(6)
  end

  it "should not add namespace to echo" do
    @namespaced.echo(123).should eq("123")
  end

  it 'should not add namespace to disconnect!' do
    expect(@redis).to receive(:disconnect!).with().and_call_original

    expect(@namespaced.disconnect!).to be nil
  end

  it "can change its namespace" do
    @namespaced.get('foo').should eq(nil)
    @namespaced.set('foo', 'chris')
    @namespaced.get('foo').should eq('chris')

    @namespaced.namespace.should eq(:ns)
    @namespaced.namespace = :spec
    @namespaced.namespace.should eq(:spec)

    @namespaced.get('foo').should eq(nil)
    @namespaced.set('foo', 'chris')
    @namespaced.get('foo').should eq('chris')
  end

  it "can accept a temporary namespace" do
    @namespaced.namespace.should eq(:ns)
    @namespaced.get('foo').should eq(nil)

    @namespaced.namespace(:spec) do |temp_ns|
      temp_ns.namespace.should eq(:spec)
      temp_ns.get('foo').should eq(nil)
      temp_ns.set('foo', 'jake')
      temp_ns.get('foo').should eq('jake')
    end

    @namespaced.namespace.should eq(:ns)
    @namespaced.get('foo').should eq(nil)
  end

  it "should respond to :namespace=" do
    @namespaced.respond_to?(:namespace=).should eq(true)
  end

  it "should respond to :warning=" do
    @namespaced.respond_to?(:warning=).should == true
  end

  it "should raise an exception when an unknown command is passed" do
    expect { @namespaced.unknown('foo') }.to raise_exception NoMethodError
  end

  # Redis 2.6 RC reports its version as 2.5.
  if @redis_version >= Gem::Version.new("2.5.0")
    describe "redis 2.6 commands" do
      it "should namespace bitcount" do
        @redis.set('ns:foo', 'foobar')
        expect(@namespaced.bitcount('foo')).to eq 26
        expect(@namespaced.bitcount('foo', 0, 0)).to eq 4
        expect(@namespaced.bitcount('foo', 1, 1)).to eq 6
        expect(@namespaced.bitcount('foo', 3, 5)).to eq 10
      end

      it "should namespace bitop" do
        try_encoding('UTF-8') do
          @redis.set("ns:foo", "a")
          @redis.set("ns:bar", "b")

          @namespaced.bitop(:and, "foo&bar", "foo", "bar")
          @namespaced.bitop(:or, "foo|bar", "foo", "bar")
          @namespaced.bitop(:xor, "foo^bar", "foo", "bar")
          @namespaced.bitop(:not, "~foo", "foo")

          expect(@redis.get("ns:foo&bar")).to eq "\x60"
          expect(@redis.get("ns:foo|bar")).to eq "\x63"
          expect(@redis.get("ns:foo^bar")).to eq "\x03"
          expect(@redis.get("ns:~foo")).to eq "\x9E"
        end
      end

      it "should namespace dump and restore" do
        @redis.set("ns:foo", "a")
        v = @namespaced.dump("foo")
        @redis.del("ns:foo")

        expect(@namespaced.restore("foo", 1000, v)).to be_true
        expect(@redis.get("ns:foo")).to eq 'a'
        expect(@redis.ttl("ns:foo")).to satisfy {|v| (0..1).include?(v) }

        @redis.rpush("ns:bar", %w(b c d))
        w = @namespaced.dump("bar")
        @redis.del("ns:bar")

        expect(@namespaced.restore("bar", 1000, w)).to be_true
        expect(@redis.lrange('ns:bar', 0, -1)).to eq %w(b c d)
        expect(@redis.ttl("ns:foo")).to satisfy {|v| (0..1).include?(v) }
      end

      it "should namespace hincrbyfloat" do
        @namespaced.hset('mykey', 'field', 10.50)
        @namespaced.hincrbyfloat('mykey', 'field', 0.1).should eq(10.6)
      end

      it "should namespace incrbyfloat" do
        @namespaced.set('mykey', 10.50)
        @namespaced.incrbyfloat('mykey', 0.1).should eq(10.6)
      end

      it "should namespace object" do
        @namespaced.set('foo', 1000)
        @namespaced.object('encoding', 'foo').should eq('int')
      end

      it "should namespace persist" do
        @namespaced.set('mykey', 'Hello')
        @namespaced.expire('mykey', 60)
        @namespaced.persist('mykey').should eq(true)
        @namespaced.ttl('mykey').should eq(-1)
      end

      it "should namespace pexpire" do
        @namespaced.set('mykey', 'Hello')
        @namespaced.pexpire('mykey', 60000).should eq(true)
      end

      it "should namespace pexpireat" do
        @namespaced.set('mykey', 'Hello')
        @namespaced.pexpire('mykey', 1555555555005).should eq(true)
      end

      it "should namespace psetex" do
        @namespaced.psetex('mykey', 10000, 'Hello').should eq('OK')
        @namespaced.get('mykey').should eq('Hello')
      end

      it "should namespace pttl" do
        @namespaced.set('mykey', 'Hello')
        @namespaced.expire('mykey', 1)
        @namespaced.pttl('mykey').should >= 0
      end

      it "should namespace eval keys passed in as array args" do
        @namespaced.
          eval("return {KEYS[1], KEYS[2]}", %w[k1 k2], %w[arg1 arg2]).
          should eq(%w[ns:k1 ns:k2])
      end

      it "should namespace eval keys passed in as hash args" do
        @namespaced.
          eval("return {KEYS[1], KEYS[2]}", :keys => %w[k1 k2], :argv => %w[arg1 arg2]).
          should eq(%w[ns:k1 ns:k2])
      end

      it "should namespace eval keys passed in as hash args unmodified" do
        args = { :keys => %w[k1 k2], :argv => %w[arg1 arg2] }
        args.freeze
        @namespaced.
          eval("return {KEYS[1], KEYS[2]}", args).
          should eq(%w[ns:k1 ns:k2])
      end

      context '#evalsha' do
        let!(:sha) do
          @redis.script(:load, "return {KEYS[1], KEYS[2]}")
        end

        it "should namespace evalsha keys passed in as array args" do
          @namespaced.
            evalsha(sha, %w[k1 k2], %w[arg1 arg2]).
            should eq(%w[ns:k1 ns:k2])
        end

        it "should namespace evalsha keys passed in as hash args" do
          @namespaced.
            evalsha(sha, :keys => %w[k1 k2], :argv => %w[arg1 arg2]).
            should eq(%w[ns:k1 ns:k2])
        end

        it "should namespace evalsha keys passed in as hash args unmodified" do
          args = { :keys => %w[k1 k2], :argv => %w[arg1 arg2] }
          args.freeze
          @namespaced.
            evalsha(sha, args).
            should eq(%w[ns:k1 ns:k2])
        end
      end

      context "in a nested namespace" do
        let(:nested_namespace) { Redis::Namespace.new(:nest, :redis => @namespaced) }
        let(:sha) { @redis.script(:load, "return {KEYS[1], KEYS[2]}") }

        it "should namespace eval keys passed in as hash args" do
          nested_namespace.
          eval("return {KEYS[1], KEYS[2]}", :keys => %w[k1 k2], :argv => %w[arg1 arg2]).
          should eq(%w[ns:nest:k1 ns:nest:k2])
        end
        it "should namespace evalsha keys passed in as hash args" do
          nested_namespace.evalsha(sha, :keys => %w[k1 k2], :argv => %w[arg1 arg2]).
            should eq(%w[ns:nest:k1 ns:nest:k2])
        end
      end
    end
  end

  # Redis 2.8 RC reports its version as 2.7.
  if @redis_version >= Gem::Version.new("2.7.105")
    describe "redis 2.8 commands" do
      context 'keyspace scan methods' do
        let(:keys) do
          %w(alpha ns:beta gamma ns:delta ns:epsilon ns:zeta:one ns:zeta:two ns:theta)
        end
        let(:namespaced_keys) do
          keys.map{|k| k.dup.sub!(/\Ans:/,'') }.compact.sort
        end
        before(:each) do
          keys.each do |key|
            @redis.set(key, key)
          end
        end
        let(:matching_namespaced_keys) do
          namespaced_keys.select{|k| k[/\Azeta:/] }.compact.sort
        end

        context '#scan' do
          context 'when :match supplied' do
            it 'should retrieve the proper keys' do
              _, result = @namespaced.scan(0, :match => 'zeta:*', :count => 1000)
              result.should =~ matching_namespaced_keys
            end
          end
          context 'without :match supplied' do
            it 'should retrieve the proper keys' do
              _, result = @namespaced.scan(0, :count => 1000)
              result.should =~ namespaced_keys
            end
          end
        end if Redis.current.respond_to?(:scan)

        context '#scan_each' do
          context 'when :match supplied' do
            context 'when given a block' do
              it 'should yield unnamespaced' do
                results = []
                @namespaced.scan_each(:match => 'zeta:*', :count => 1000) {|k| results << k }
                results.should =~ matching_namespaced_keys
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that un-namespaces' do
                enum = @namespaced.scan_each(:match => 'zeta:*', :count => 1000)
                enum.to_a.should =~ matching_namespaced_keys
              end
            end
          end
          context 'without :match supplied' do
            context 'when given a block' do
              it 'should yield unnamespaced' do
                results = []
                @namespaced.scan_each(:count => 1000){ |k| results << k }
                results.should =~ namespaced_keys
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that un-namespaces' do
                enum = @namespaced.scan_each(:count => 1000)
                enum.to_a.should =~ namespaced_keys
              end
            end
          end
        end if Redis.current.respond_to?(:scan_each)
      end

      context 'hash scan methods' do
        before(:each) do
          @redis.mapped_hmset('hsh', {'zeta:wrong:one' => 'WRONG', 'wrong:two' => 'WRONG'})
          @redis.mapped_hmset('ns:hsh', hash)
        end
        let(:hash) do
          {'zeta:one' => 'OK', 'zeta:two' => 'OK', 'three' => 'OKAY'}
        end
        let(:hash_matching_subset) do
          # select is not consistent from 1.8.7 -> 1.9.2 :(
          hash.reject {|k,v| !k[/\Azeta:/] }
        end
        context '#hscan' do
          context 'when supplied :match' do
            it 'should retrieve the proper keys' do
              _, results = @namespaced.hscan('hsh', 0, :match => 'zeta:*')
              results.should =~ hash_matching_subset.to_a
            end
          end
          context 'without :match supplied' do
            it 'should retrieve all hash keys' do
              _, results = @namespaced.hscan('hsh', 0)
              results.should =~ @redis.hgetall('ns:hsh').to_a
            end
          end
        end if Redis.current.respond_to?(:hscan)

        context '#hscan_each' do
          context 'when :match supplied' do
            context 'when given a block' do
              it 'should yield the correct hash keys unchanged' do
                results = []
                @namespaced.hscan_each('hsh', :match => 'zeta:*', :count => 1000) { |kv| results << kv}
                results.should =~ hash_matching_subset.to_a
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields the correct hash keys unchanged' do
                enum = @namespaced.hscan_each('hsh', :match => 'zeta:*', :count => 1000)
                enum.to_a.should =~ hash_matching_subset.to_a
              end
            end
          end
          context 'without :match supplied' do
            context 'when given a block' do
              it 'should yield all hash keys unchanged' do
                results = []
                @namespaced.hscan_each('hsh', :count => 1000){ |k| results << k }
                results.should =~ hash.to_a
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields all keys unchanged' do
                enum = @namespaced.hscan_each('hsh', :count => 1000)
                enum.to_a.should =~ hash.to_a
              end
            end
          end
        end if Redis.current.respond_to?(:hscan_each)
      end

      context 'set scan methods' do
        before(:each) do
          set.each { |elem| @namespaced.sadd('set', elem) }
          @redis.sadd('set', 'WRONG')
        end
        let(:set) do
          %w(zeta:one zeta:two three)
        end
        let(:matching_subset) do
          set.select { |e| e[/\Azeta:/] }
        end

        context '#sscan' do
          context 'when supplied :match' do
            it 'should retrieve the matching set members from the proper set' do
              _, results = @namespaced.sscan('set', 0, :match => 'zeta:*', :count => 1000)
              results.should =~ matching_subset
            end
          end
          context 'without :match supplied' do
            it 'should retrieve all set members from the proper set' do
              _, results = @namespaced.sscan('set', 0, :count => 1000)
              results.should =~ set
            end
          end
        end if Redis.current.respond_to?(:sscan)

        context '#sscan_each' do
          context 'when :match supplied' do
            context 'when given a block' do
              it 'should yield the correct hset elements unchanged' do
                results = []
                @namespaced.sscan_each('set', :match => 'zeta:*', :count => 1000) { |kv| results << kv}
                results.should =~ matching_subset
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields the correct set elements unchanged' do
                enum = @namespaced.sscan_each('set', :match => 'zeta:*', :count => 1000)
                enum.to_a.should =~ matching_subset
              end
            end
          end
          context 'without :match supplied' do
            context 'when given a block' do
              it 'should yield all set elements unchanged' do
                results = []
                @namespaced.sscan_each('set', :count => 1000){ |k| results << k }
                results.should =~ set
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields all set elements unchanged' do
                enum = @namespaced.sscan_each('set', :count => 1000)
                enum.to_a.should =~ set
              end
            end
          end
        end if Redis.current.respond_to?(:sscan_each)
      end

      context 'zset scan methods' do
        before(:each) do
          hash.each {|member, score| @namespaced.zadd('zset', score, member)}
          @redis.zadd('zset', 123.45, 'WRONG')
        end
        let(:hash) do
          {'zeta:one' => 1, 'zeta:two' => 2, 'three' => 3}
        end
        let(:hash_matching_subset) do
          # select is not consistent from 1.8.7 -> 1.9.2 :(
          hash.reject {|k,v| !k[/\Azeta:/] }
        end
        context '#zscan' do
          context 'when supplied :match' do
            it 'should retrieve the matching set elements and their scores' do
              results = []
              @namespaced.zscan_each('zset', :match => 'zeta:*', :count => 1000) { |ms| results << ms }
              results.should =~ hash_matching_subset.to_a
            end
          end
          context 'without :match supplied' do
            it 'should retrieve all set elements and their scores' do
              results = []
              @namespaced.zscan_each('zset', :count => 1000) { |ms| results << ms }
              results.should =~ hash.to_a
            end
          end
        end if Redis.current.respond_to?(:zscan)

        context '#zscan_each' do
          context 'when :match supplied' do
            context 'when given a block' do
              it 'should yield the correct set elements and scores unchanged' do
                results = []
                @namespaced.zscan_each('zset', :match => 'zeta:*', :count => 1000) { |ms| results << ms}
                results.should =~ hash_matching_subset.to_a
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields the correct set elements and scoresunchanged' do
                enum = @namespaced.zscan_each('zset', :match => 'zeta:*', :count => 1000)
                enum.to_a.should =~ hash_matching_subset.to_a
              end
            end
          end
          context 'without :match supplied' do
            context 'when given a block' do
              it 'should yield all set elements and scores unchanged' do
                results = []
                @namespaced.zscan_each('zset', :count => 1000){ |ms| results << ms }
                results.should =~ hash.to_a
              end
            end
            context 'without a block' do
              it 'should return an Enumerator that yields all set elements and scores unchanged' do
                enum = @namespaced.zscan_each('zset', :count => 1000)
                enum.to_a.should =~ hash.to_a
              end
            end
          end
        end if Redis.current.respond_to?(:zscan_each)
      end
    end
  end

  if @redis_version >= Gem::Version.new("2.8.9")
    it 'should namespace pfadd' do
      5.times { |n| @namespaced.pfadd("pf", n) }
      @redis.pfcount("ns:pf").should == 5
    end

    it 'should namespace pfcount' do
      5.times { |n| @redis.pfadd("ns:pf", n) }
      @namespaced.pfcount("pf").should == 5
    end

    it 'should namespace pfmerge' do
      5.times do |n|
        @redis.pfadd("ns:pfa", n)
        @redis.pfadd("ns:pfb", n+5)
      end

      @namespaced.pfmerge("pfc", "pfa", "pfb")
      @redis.pfcount("ns:pfc").should == 10
    end
  end
end
