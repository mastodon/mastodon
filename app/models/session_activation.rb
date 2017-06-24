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
#  browser    :string           default(""), not null
#  platform   :string           default(""), not null
#  ip         :inet
#

class SessionActivation < ApplicationRecord
  class << self
    def active?(id)
      id && where(session_id: id).exists?
    end

    def activate(options = {})
      activation = create!(options)
      purge_old
      activation
    end

    def deactivate(id)
      return unless id
      where(session_id: id).destroy_all
    end

    def purge_old
      order('created_at desc').offset(Rails.configuration.x.max_session_activations).destroy_all
    end

    def exclusive(id)
      where('session_id != ?', id).destroy_all
    end
  end
end
