# frozen_string_literal: true

class FixKmrLocaleSettings < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def up
    MigrationUser.reset_column_information

    MigrationUser.where.not(settings: [nil, '{}']).find_each do |user|
      user_settings = Oj.load(user.settings)
      next unless user_settings['default_language'] == 'kmr'

      user_settings['default_language'] = 'ku'
      user.update!(settings: Oj.dump(user_settings))
    end

    MigrationUser.where.not(chosen_languages: nil).where('chosen_languages && ?', '{kmr}').find_each do |user|
      user.update!(chosen_languages: user.chosen_languages.map { |lang| lang == 'kmr' ? 'ku' : lang }.uniq)
    end
  end

  def down; end
end
