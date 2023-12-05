# frozen_string_literal: true

class AddTemplateToWebhooks < ActiveRecord::Migration[6.1]
  def change
    add_column :webhooks, :template, :text
  end
end
