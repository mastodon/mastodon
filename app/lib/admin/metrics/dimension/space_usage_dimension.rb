# frozen_string_literal: true

class Admin::Metrics::Dimension::SpaceUsageDimension < Admin::Metrics::Dimension::BaseDimension
  include ActionView::Helpers::NumberHelper
  include Admin::Metrics::Dimension::StoreHelper

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
    {
      key: 'redis',
      human_key: store_name,
      value: store_size.to_s,
      unit: 'bytes',
      human_value: number_to_human_size(store_size),
    }
  end

  def media_size
    value = [
      MediaAttachment.sum(MediaAttachment.combined_media_file_size),
      CustomEmoji.sum(:image_file_size),
      PreviewCard.sum(:image_file_size),
      Account.sum(Arel.sql('COALESCE(avatar_file_size, 0) + COALESCE(header_file_size, 0)')),
      Backup.sum(:dump_file_size),
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
