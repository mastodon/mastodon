# == Schema Information
#
# Table name: emoji_favourites
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  custom_emoji_id :integer          not null
#

class EmojiFavourite < ApplicationRecord
  include Paginable

  belongs_to :user, inverse_of: :emoji_favourites, required: true
  belongs_to :custom_emoji,  inverse_of: :favourites, required: true
end
