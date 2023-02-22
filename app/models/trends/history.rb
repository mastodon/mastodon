# frozen_string_literal: true

class Trends::History
  include Enumerable

  class Aggregate
    include Redisable

    def initialize(prefix, id, date_range)
      @days = date_range.map { |date| Day.new(prefix, id, date.to_time(:utc)) }
    end

    def uses
      with_redis { |redis| redis.mget(*@days.map { |day| day.key_for(:uses) }).map(&:to_i).sum }
    end

    def accounts
      with_redis { |redis| redis.pfcount(*@days.map { |day| day.key_for(:accounts) }) }
    end
  end

  class Day
    include Redisable

    EXPIRE_AFTER = 14.days.seconds

    def initialize(prefix, id, day)
      @prefix = prefix
      @id     = id
      @day    = day.beginning_of_day
    end

    attr_reader :day

    def accounts
      with_redis { |redis| redis.pfcount(key_for(:accounts)) }
    end

    def uses
      with_redis { |redis| redis.get(key_for(:uses))&.to_i || 0 }
    end

    def add(account_id)
      with_redis do |redis|
        redis.pipelined do |pipeline|
          pipeline.incrby(key_for(:uses), 1)
          pipeline.pfadd(key_for(:accounts), account_id)
          pipeline.expire(key_for(:uses), EXPIRE_AFTER)
          pipeline.expire(key_for(:accounts), EXPIRE_AFTER)
        end
      end
    end

    def as_json
      { day: day.to_i.to_s, accounts: accounts.to_s, uses: uses.to_s }
    end

    def key_for(suffix)
      case suffix
      when :accounts
        "#{key_prefix}:#{suffix}"
      when :uses
        key_prefix
      end
    end

    def key_prefix
      "activity:#{@prefix}:#{@id}:#{day.to_i}"
    end
  end

  def initialize(prefix, id)
    @prefix = prefix
    @id     = id
  end

  def get(date)
    Day.new(@prefix, @id, date)
  end

  def add(account_id, at_time = Time.now.utc)
    Day.new(@prefix, @id, at_time).add(account_id)
  end

  def aggregate(date_range)
    Aggregate.new(@prefix, @id, date_range)
  end

  def each(&block)
    if block
      (0...7).map { |i| yield(get(i.days.ago)) }
    else
      to_enum(:each)
    end
  end

  def as_json(*)
    map(&:as_json)
  end
end
