# frozen_string_literal: true
# == Schema Information
#
# Table name: session_activations
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SessionActivation < ApplicationRecord
  LIMIT = Rails.configuration.x.max_session_activations

  def self.active?(id)
    id && where(session_id: id).exists?
  end

  def self.activate(id)
    activation = create!(session_id: id)
    purge_old
    activation
  end

  def self.deactivate(id)
    return unless id
    where(session_id: id).destroy_all
  end

  def self.purge_old
    order('created_at desc').offset(LIMIT).destroy_all
  end

  def self.exclusive(id)
    where('session_id != ?', id).destroy_all
  end
end
