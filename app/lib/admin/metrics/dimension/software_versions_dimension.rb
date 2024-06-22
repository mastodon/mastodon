# frozen_string_literal: true

class Admin::Metrics::Dimension::SoftwareVersionsDimension < Admin::Metrics::Dimension::BaseDimension
  include Redisable

  def key
    'software_versions'
  end

  protected

  def perform_query
    [mastodon_version, ruby_version, postgresql_version, redis_version, elasticsearch_version, libvips_version, imagemagick_version, ffmpeg_version].compact
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
    {
      key: 'ruby',
      human_key: 'Ruby',
      value: RUBY_DESCRIPTION,
      human_value: "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}",
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

  def libvips_version
    return unless Rails.configuration.x.use_vips

    {
      key: 'libvips',
      human_key: 'libvips',
      value: Vips.version_string,
      human_value: Vips.version_string,
    }
  end

  def imagemagick_version
    return if Rails.configuration.x.use_vips

    version = `convert -version`.match(/Version: ImageMagick ([\d\.]+)/)[1]

    {
      key: 'imagemagick',
      human_key: 'ImageMagick',
      value: version,
      human_value: version,
    }
  rescue Errno::ENOENT
    nil
  end

  def ffmpeg_version
    version = `ffmpeg -version`.match(/ffmpeg version ([\d\.]+)/)[1]

    {
      key: 'ffmpeg',
      human_key: 'FFmpeg',
      value: version,
      human_value: version,
    }
  rescue Errno::ENOENT
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
