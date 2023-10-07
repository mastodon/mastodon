# frozen_string_literal: true

class Admin::Metrics::Dimension::SpaceUsageDimension < Admin::Metrics::Dimension::BaseDimension
  include Redisable
  include ActionView::Helpers::NumberHelper

  def key
    'space_usage'
  end

  protected

  def perform_query
    [postgresql_size, redis_size, media_size, search_size].compact
  end

  def postgresql_size
    value = ActiveRecord::Base.connection.execute('SELECT pg_database_size(current_database())').first['pg_database_size']

    {
      key: 'postgresql',
      human_key: 'PostgreSQL',
      value: value.to_s,
      unit: 'bytes',
      human_value: number_to_human_size(value),
    }
  end

  def redis_size
    value = redis_info['used_memory']

    {
      key: 'redis',
      human_key: 'Redis',
      value: value.to_s,
      unit: 'bytes',
      human_value: number_to_human_size(value),
    }
  end

  def media_size
    value = [
      MediaAttachment.sum(Arel.sql('COALESCE(file_file_size, 0) + COALESCE(thumbnail_file_size, 0)')),
      CustomEmoji.sum(:image_file_size),
      PreviewCard.sum(:image_file_size),
      Account.sum(Arel.sql('COALESCE(avatar_file_size, 0) + COALESCE(header_file_size, 0)')),
      Backup.sum(:dump_file_size),
      Import.sum(:data_file_size),
      SiteUpload.sum(:file_file_size),
    ].sum

    {
      key: 'media',
      human_key: I18n.t('admin.dashboard.media_storage'),
      value: value.to_s,
      unit: 'bytes',
      human_value: number_to_human_size(value),
    }
  end

  def redis_info
    @redis_info ||= if redis.is_a?(Redis::Namespace)
                      redis.redis.info
                    else
                      redis.info
                    end
  end

  def search_size
    return unless Chewy.enabled?

    client_info = Chewy.client.info

    value = Chewy.client.indices.stats['indices'].values.sum { |index_data| index_data['primaries']['store']['size_in_bytes'] }

    {
      key: 'search',
      human_key: client_info.dig('version', 'distribution') == 'opensearch' ? 'OpenSearch' : 'Elasticsearch',
      value: value.to_s,
      unit: 'bytes',
      human_value: number_to_human_size(value),
    }
  rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
    nil
  end
end
