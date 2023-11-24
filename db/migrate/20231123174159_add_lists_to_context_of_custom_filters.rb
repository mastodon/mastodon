# frozen_string_literal: true

class AddListsToContextOfCustomFilters < ActiveRecord::Migration[7.1]
  def up
    CustomFilter.where('context @> ?', '{"home"}').update_all(['context = context || ?', '{"lists"}']) # rubocop:disable Rails::SkipsModelValidations
  end

  def down
    CustomFilter.where('context @> ?', '{"lists"}').update_all(['context = array_remove(context, ?)', '{"lists"}']) # rubocop:disable Rails::SkipsModelValidations
  end
end
