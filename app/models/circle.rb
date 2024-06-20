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
#  list_id    :bigint(8)
#
class Circle < ApplicationRecord
  include Paginable

  belongs_to :account

  has_many :circle_accounts, inverse_of: :circle, dependent: :destroy
  has_many :accounts, through: :circle_accounts

  belongs_to :list, optional: true, dependent: :destroy

  validates :title, presence: true

  before_create :create_corresponding_list

  private

  def create_corresponding_list
    create_list(title: title, account_id: account_id)
  end
end
