# frozen_string_literal: true
# == Schema Information
#
# Table name: recently_used_tags
#
#  id         :integer          not null, primary key
#  index      :integer          not null
#  account_id :integer          not null
#  tag_id     :string           not null
#

class RecentlyUsedTag < ApplicationRecord
  belongs_to :account, inverse_of: :recently_used_tags
  belongs_to :tag, inverse_of: :recently_used_tags, primary_key: :name

  scope :recent, -> { reorder(id: :desc) }
end
