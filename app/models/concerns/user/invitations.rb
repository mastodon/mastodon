# frozen_string_literal: true

module User::Invitations
  extend ActiveSupport::Concern

  included do
    belongs_to :invite, counter_cache: :uses, optional: true
  end
end
