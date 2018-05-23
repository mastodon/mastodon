require_relative 'spec_helper'

describe 'Rack::Attack.Fail2Ban' do
  before do
    # Use a long findtime; failures due to cache key rotation less likely
    @cache = Rack::Attack.cache
    @findtime = 60
    @bantime  = 60
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    @f2b_options = {:bantime => @bantime, :findtime => @findtime, :maxretry => 2}

    Rack::Attack.blocklist('pentest') do |req|
      Rack::Attack::Fail2Ban.filter(req.ip, @f2b_options){req.query_string =~ /OMGHAX/}
    end
  end

  describe 'discriminator has not been banned' do
    describe 'making ok request' do
      it 'succeeds' do
        get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'
        last_response.status.must_equal 200
      end
    end

    describe 'making failing request' do
      describe 'when not at maxretry' do
        before { get '/?foo=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4' }

        it 'fails' do
          last_response.status.must_equal 403
        end

        it 'increases fail count' do
          key = "rack::attack:#{Time.now.to_i/@findtime}:fail2ban:count:1.2.3.4"
          @cache.store.read(key).must_equal 1
        end

        it 'is not banned' do
          key = "rack::attack:fail2ban:1.2.3.4"
          @cache.store.read(key).must_be_nil
        end
      end

      describe 'when at maxretry' do
        before do
          # maxretry is 2 - so hit with an extra failed request first
          get '/?test=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
          get '/?foo=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
        end

        it 'fails' do
          last_response.status.must_equal 403
        end

        it 'increases fail count' do
          key = "rack::attack:#{Time.now.to_i/@findtime}:fail2ban:count:1.2.3.4"
          @cache.store.read(key).must_equal 2
        end

        it 'is banned' do
          key = "rack::attack:fail2ban:ban:1.2.3.4"
          @cache.store.read(key).must_equal 1
        end
      end

      describe 'reset after success' do
        before do
          get '/?test=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
          Rack::Attack::Fail2Ban.reset('1.2.3.4', @f2b_options)
          get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'
        end

        it 'succeeds' do
          last_response.status.must_equal 200
        end

        it 'resets fail count' do
          key = "rack::attack:#{Time.now.to_i/@findtime}:fail2ban:count:1.2.3.4"
          assert_nil @cache.store.read(key)
        end

        it 'IP is not banned' do
          Rack::Attack::Fail2Ban.banned?('1.2.3.4').must_equal false
        end
      end
    end
  end

  describe 'discriminator has been banned' do
    before do
      # maxretry is 2 - so hit enough times to get banned
      get '/?test=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
      get '/?foo=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
    end

    describe 'making request for other discriminator' do
      it 'succeeds' do
        get '/', {}, 'REMOTE_ADDR' => '2.2.3.4'
        last_response.status.must_equal 200
      end
    end

    describe 'making ok request' do
      before do
        get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'
      end

      it 'fails' do
        last_response.status.must_equal 403
      end

      it 'does not increase fail count' do
        key = "rack::attack:#{Time.now.to_i/@findtime}:fail2ban:count:1.2.3.4"
        @cache.store.read(key).must_equal 2
      end

      it 'is still banned' do
        key = "rack::attack:fail2ban:ban:1.2.3.4"
        @cache.store.read(key).must_equal 1
      end
    end

    describe 'making failing request' do
      before do
        get '/?foo=OMGHAX', {}, 'REMOTE_ADDR' => '1.2.3.4'
      end

      it 'fails' do
        last_response.status.must_equal 403
      end

      it 'does not increase fail count' do
        key = "rack::attack:#{Time.now.to_i/@findtime}:fail2ban:count:1.2.3.4"
        @cache.store.read(key).must_equal 2
      end

      it 'is still banned' do
        key = "rack::attack:fail2ban:ban:1.2.3.4"
        @cache.store.read(key).must_equal 1
      end
    end
  end
end
