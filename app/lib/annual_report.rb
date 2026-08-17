# frozen_string_literal: true

class AnnualReport
  include DatabaseHelper

  SOURCES = [
    AnnualReport::Archetype,
    AnnualReport::TopStatuses,
    AnnualReport::TimeSeries,
    AnnualReport::TopHashtags,
  ].freeze

  SCHEMA = 2

  def self.table_name_prefix
    'annual_report_'
  end

  def self.current_campaign
    return unless Setting.wrapstodon

    datetime = Time.now.utc
    datetime.year if datetime.month == 12 && (10..31).cover?(datetime.day)
  end

  def initialize(account, year)
    @account = account
    @year = year
  end

  def eligible?
    with_read_replica do
      SOURCES.all? { |klass| klass.new(@account, @year).eligible? }
    end
  end

  def state
    return 'available' if GeneratedAnnualReport.exists?(account_id: @account.id, year: @year)

    async_refresh = AsyncRefresh.new(refresh_key)

    if async_refresh.running?
      yield async_refresh if block_given?
      'generating'
    elsif AnnualReport.current_campaign == @year && eligible?
      'eligible'
    else
      'ineligible'
    end
  end

  def refresh_key
    "wrapstodon:#{@account.id}:#{@year}"
  end

  def generate
    return if GeneratedAnnualReport.exists?(account: @account, year: @year)

    GeneratedAnnualReport.create(
      account: @account,
      year: @year,
      schema_version: SCHEMA,
      data: data,
      share_key: SecureRandom.hex(8)
    )
  end

  private

  def data
    with_read_replica do
      SOURCES.each_with_object({}) { |klass, hsh| hsh.merge!(klass.new(@account, @year).generate) }
    end
  end
end
