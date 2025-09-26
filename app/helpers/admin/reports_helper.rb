# frozen_string_literal: true

module Admin::ReportsHelper
  def explanation_key(action)
    explanation_mapping.fetch(action) { action }
  end

  private

  def explanation_mapping
    {
      'delete' => 'delete_statuses',
      'mark_as_sensitive' => 'mark_statuses_as_sensitive',
    }
  end
end
