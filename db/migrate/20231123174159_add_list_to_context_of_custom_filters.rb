# frozen_string_literal: true

class AddListToContextOfCustomFilters < ActiveRecord::Migration[7.1]
  def up
    CustomFilter.where('context @> ?', '{"home"}').update_all(['context = context || ?', '{"list"}']) # rubocop:disable Rails::SkipsModelValidations
  end

  def down
    CustomFilter.where('context @> ?', '{"list"}').update_all(['context = array_remove(context, ?)', '{"list"}']) # rubocop:disable Rails::SkipsModelValidations
  end
end
