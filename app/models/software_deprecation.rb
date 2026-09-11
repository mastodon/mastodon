# frozen_string_literal: true

# == Schema Information
#
# Table name: software_deprecations
#
#  id             :bigint(8)        not null, primary key
#  branch         :string           not null
#  end_of_support :date             not null
#  warning_issued :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class SoftwareDeprecation < ApplicationRecord
  enum :warning_issued, {
    none: 0,
    three_months_warning: 1,
    two_weeks_warning: 2,
    out_of_support_warning: 3,
  }, validate: true, suffix: :issued

  def unsupported?
    end_of_support.past?
  end

  def self.clear_irrelevant_branches!
    where.not(branch: current_branch).delete_all
  end

  def self.current
    find_by(branch: current_branch)
  end

  def self.current_branch
    Mastodon::Version.gem_version.segments[...2].join('.')
  end
end
