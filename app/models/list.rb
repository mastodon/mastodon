# frozen_string_literal: true
# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  account_id :integer
#  title      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class List < ApplicationRecord
  include Paginable

  belongs_to :account

  has_many :list_accounts, inverse_of: :list, dependent: :destroy
  has_many :accounts, through: :list_accounts

  validates :title, presence: true
end
