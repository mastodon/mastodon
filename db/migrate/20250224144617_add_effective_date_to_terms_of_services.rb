# frozen_string_literal: true

class AddEffectiveDateToTermsOfServices < ActiveRecord::Migration[8.0]
  def change
    add_column :terms_of_services, :effective_date, :date
  end
end
