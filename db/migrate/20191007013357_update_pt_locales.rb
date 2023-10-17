# frozen_string_literal: true

class UpdatePtLocales < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  disable_ddl_transaction!

  def up
    User.where(locale: 'pt').in_batches.update_all(locale: 'pt-PT')
  end

  def down
    User.where(locale: 'pt-PT').in_batches.update_all(locale: 'pt')
  end
end
