# frozen_string_literal: true

class Admin::Metrics::Dimension::SoftwareVersionsDimension < Admin::Metrics::Dimension::BaseDimension
  include Redisable

  def key
    'software_versions'
  end

  protected

  def perform_query
    [mastodon_version, ruby_version, postgresql_version, redis_version, elasticsearch_version].compact
  end

  def mastodon_version
    value = Mastodon::Version.to_s

    {
      key: 'mastodon',
      human_key: 'Mastodon',
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

  def elasticsearch_version
    return unless Chewy.enabled?

    client_info = Chewy.client.info
    version = client_info.dig('version', 'number')

    {
      key: 'elasticsearch',
      human_key: client_info.dig('version', 'distribution') == 'opensearch' ? 'OpenSearch' : 'Elasticsearch',
      value: version,
      human_value: version,
    }
  rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
    nil
  end

  def redis_info
    @redis_info ||= if redis.is_a?(Redis::Namespace)
                      redis.redis.info
                    else
                      redis.info
                    end
  end
end
