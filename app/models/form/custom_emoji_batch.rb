# frozen_string_literal: true

class Form::CustomEmojiBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern

  attr_accessor :custom_emoji_ids, :action, :current_account,
                :category_id, :category_name, :visible_in_picker

  def save
    case action
    when 'update'
      update!
    when 'list'
      list!
    when 'unlist'
      unlist!
    when 'enable'
      enable!
    when 'disable'
      disable!
    when 'copy'
      copy!
    when 'delete'
      delete!
    end
  end

  private

  def custom_emojis
    CustomEmoji.where(id: custom_emoji_ids)
  end

  def update!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :update?) }

    category = begin
      if category_id.present?
        CustomEmojiCategory.find(category_id)
      elsif category_name.present?
        CustomEmojiCategory.find_or_create_by!(name: category_name)
      end
    end

    custom_emojis.each do |custom_emoji|
      custom_emoji.update(category_id: category&.id)
      log_action :update, custom_emoji
    end
  end

  def list!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :update?) }

    custom_emojis.each do |custom_emoji|
      custom_emoji.update(visible_in_picker: true)
      log_action :update, custom_emoji
    end
  end

  def unlist!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :update?) }

    custom_emojis.each do |custom_emoji|
      custom_emoji.update(visible_in_picker: false)
      log_action :update, custom_emoji
    end
  end

  def enable!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :enable?) }

    custom_emojis.each do |custom_emoji|
      custom_emoji.update(disabled: false)
      log_action :enable, custom_emoji
    end
  end

  def disable!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :disable?) }

    custom_emojis.each do |custom_emoji|
      custom_emoji.update(disabled: true)
      log_action :disable, custom_emoji
    end
  end

  def copy!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :copy?) }

    custom_emojis.each do |custom_emoji|
      copied_custom_emoji = custom_emoji.copy!
      log_action :create, copied_custom_emoji
    end
  end

  def delete!
    custom_emojis.each { |custom_emoji| authorize(custom_emoji, :destroy?) }

    custom_emojis.each do |custom_emoji|
      custom_emoji.destroy
      log_action :destroy, custom_emoji
    end
  end
end
