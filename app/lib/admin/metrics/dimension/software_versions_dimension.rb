# frozen_string_literal: true

class Admin::Metrics::Dimension::SoftwareVersionsDimension < Admin::Metrics::Dimension::BaseDimension
  include Redisable

  def key
    'software_versions'
  end

  protected

  def perform_query
    [mastodon_version, ruby_version, postgresql_version, redis_version]
  end

  def mastodon_version
    value = Mastodon::Version.to_s

    {
      key: 'mastodon',
      human_key: 'Hometown',
      value: value,
      human_value: value,
    }
  end

  def ruby_version
    value = "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"

    {
      key: 'ruby',
      human_key: 'Ruby',
      value: value,
      human_value: value,
    }
  end

  def postgresql_version
    value = ActiveRecord::Base.connection.execute('SELECT VERSION()').first['version'].match(/\A(?:PostgreSQL |)([^\s]+).*\z/)[1]

    {
      key: 'postgresql',
      human_key: 'PostgreSQL',
      value: value,
      human_value: value,
    }
  end

  def redis_version
    value = redis_info['redis_version']

    {
      key: 'redis',
      human_key: 'Redis',
      value: value,
      human_value: value,
    }
  end

  def redis_info
    @redis_info ||= begin
      if redis.is_a?(Redis::Namespace)
        redis.redis.info
      else
        redis.info
      end
    end
  end
end
