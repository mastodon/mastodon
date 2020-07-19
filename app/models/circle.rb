# frozen_string_literal: true

# == Schema Information
#
# Table name: circles
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  title      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Circle < ApplicationRecord
  include Paginable

  belongs_to :account

  has_many :circle_accounts, inverse_of: :circle, dependent: :destroy
  has_many :accounts, through: :circle_accounts

  validates :title, presence: true
end
