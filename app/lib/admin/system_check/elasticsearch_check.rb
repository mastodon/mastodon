# frozen_string_literal: true

class Admin::SystemCheck::ElasticsearchCheck < Admin::SystemCheck::BaseCheck
  def pass?
    return true unless Chewy.enabled?

    running_version.present? && compatible_version?
  end

  def message
    if running_version.present?
      Admin::SystemCheck::Message.new(:elasticsearch_version_check, I18n.t('admin.system_checks.elasticsearch_version_check.version_comparison', running_version: running_version, required_version: required_version))
    else
      Admin::SystemCheck::Message.new(:elasticsearch_running_check)
    end
  end

  private

  def running_version
    @running_version ||= begin
      Chewy.client.info['version']['number']
    rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
      nil
    end
  end

  def required_version
    '7.x'
  end

  def compatible_version?
    Gem::Version.new(running_version) >= Gem::Version.new(required_version)
  end

  def missing_queues
    @missing_queues ||= Sidekiq::ProcessSet.new.reduce(SIDEKIQ_QUEUES) { |queues, process| queues - process['queues'] }
  end
end
