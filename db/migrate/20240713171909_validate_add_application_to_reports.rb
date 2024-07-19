# frozen_string_literal: true

class ValidateAddApplicationToReports < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :reports, :oauth_applications
  end
end
