# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, raw_tags = [])
    @status        = status
    @account       = status.account
    @raw_tags      = status.local? ? Extractor.extract_hashtags(status.text) : raw_tags
    @previous_tags = status.tags.to_a
    @current_tags  = []

    assign_tags!
    update_featured_tags!
  end

  private

  def assign_tags!
    @status.tags = @current_tags = Tag.find_or_create_by_names(@raw_tags)
  end

  def update_featured_tags!
    return unless @status.distributable?

    process_added_tags! unless added_tags.empty?

    process_removed_tags! unless removed_tags.empty?
  end

  def process_added_tags!
    featured_tags_on(added_tags).find_each do |featured_tag|
      featured_tag.increment(@status.created_at)
    end
  end

  def process_removed_tags!
    featured_tags_on(removed_tags).find_each do |featured_tag|
      featured_tag.decrement(@status)
    end
  end

  def featured_tags_on(tags)
    @account.featured_tags.where(tag_id: tags.map(&:id))
  end

  def added_tags
    @current_tags - @previous_tags
  end

  def removed_tags
    @previous_tags - @current_tags
  end
end
