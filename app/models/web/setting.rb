# frozen_string_literal: true

class Web::Setting < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: true
end
