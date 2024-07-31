# frozen_string_literal: true

# == Schema Information
#
# Table name: taggings
#
#  id            :bigint(8)        not null, primary key
#  tag_id        :bigint(8)        not null
#  taggable_type :string           not null
#  taggable_id   :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
