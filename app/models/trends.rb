# frozen_string_literal: true

module Trends
  def self.table_name_prefix
    'trends_'
  end

  def self.links
    @links ||= Trends::Links.new
  end

  def self.tags
    @tags ||= Trends::Tags.new
  end

  def self.refresh!
    [links, tags].each(&:refresh)
  end

  def self.request_review!
    [links, tags].each(&:request_review)
  end
end
