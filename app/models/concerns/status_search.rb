# frozen_string_literal: true

module StatusSearch
  extend ActiveSupport::Concern

  def publicly_searchable?
    public_visibility? && account.discoverable?
  end
end
