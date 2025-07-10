# frozen_string_literal: true

# == Schema Information
#
# Table name: annual_report_statuses_per_account_counts
#
#  id             :bigint(8)        not null, primary key
#  year           :integer          not null
#  account_id     :bigint(8)        not null
#  statuses_count :bigint(8)        not null
#

class AnnualReport::StatusesPerAccountCount < ApplicationRecord
  def self.refresh(year)
    connection.exec_query(<<~SQL.squish)
      INSERT INTO #{table_name} (year, account_id, statuses_count)
      #{AccountStatusCountQuery.new(year)}
      ON CONFLICT (year, account_id) DO NOTHING
    SQL
  end

  class AccountStatusCountQuery
    def initialize(year)
      @year = year
    end

    def to_s
      Status
        .unscoped
        .local
        .where(id: beginning_of_year..end_of_year)
        .group(:account_id)
        .select(@year, :account_id, Arel.star.count)
        .to_sql
    end

    def beginning_of_year
      Mastodon::Snowflake.id_at(DateTime.new(@year).beginning_of_year, with_random: false)
    end

    def end_of_year
      Mastodon::Snowflake.id_at(DateTime.new(@year).end_of_year, with_random: false)
    end
  end
end
