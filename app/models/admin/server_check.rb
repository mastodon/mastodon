# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_server_checks
#
#  id         :bigint(8)        not null, primary key
#  checked_at :datetime
#  data       :jsonb
#  ignored    :boolean          default(FALSE), not null
#  key        :string           not null
#  severity   :integer          default("critical"), not null
#  status     :integer          default("unprocessed"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Admin::ServerCheck < ApplicationRecord
  RUNNERS = [
    Admin::ServerCheck::SoftwareVersionRunner,
    Admin::ServerCheck::MediaPrivacyRunner,
    Admin::ServerCheck::DatabaseSchemaRunner,
    Admin::ServerCheck::SidekiqProcessRunner,
    Admin::ServerCheck::RulesRunner,
    Admin::ServerCheck::ElasticSearchRunner,
  ].freeze

  enum :status, { unprocessed: 0, running: 1, ok: 2, pending: 3, error: 4 }
  enum :severity, { critical: 0, warning: 1, suggestion: 2 }

  delegate :async?, :sync?, :authorized?, to: :runner

  def self.checks
    keys = RUNNERS.map(&:key)
    records = where(key: keys).to_a

    missing = keys - records.map(&:key)
    checks = records + missing.map { |key| new(key:) }

    checks.sort_by(&:key)
  end

  def self.checks_for(user)
    checks.filter_map do |check|
      next unless check.authorized?(user)

      check.tap(&:prepare)
    end
  end

  def prepare
    run if sync?
  end

  def run
    result = runner.run

    self.status = result.status
    self.data = result.data
    self.severity = result.severity
  rescue => e
    self.status = :error
    self.data = { error: e.message }

    yield e if block_given?
  ensure
    self.checked_at = DateTime.now
  end

  def run!
    run { |e| raise e }
  end

  def runner
    @runner ||= RUNNERS.find { |r| r.key == key }&.new || Admin::ServerCheck::NoopRunner.new
  end

  def key=(value)
    super.tap do
      @runner = nil if key_changed?
    end
  end

  def reload(*)
    super.tap do
      @runner = nil
    end
  end

  def data
    super || {}
  end

  def category
    return 'ignored' if ignored?
    return 'completed' if ok?
    return 'unprocessed' if unprocessed? || running?
    return 'error' if error?

    severity
  end
end
