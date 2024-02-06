# frozen_string_literal: true

class AddCommentToInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :invites, :comment, :text
  end
end
