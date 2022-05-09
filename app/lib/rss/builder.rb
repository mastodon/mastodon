# frozen_string_literal: true

class RSS::Builder
  attr_reader :dsl

  def self.build
    new.tap do |builder|
      yield builder.dsl
    end.to_xml
  end

  def initialize
    @dsl = RSS::Channel.new
  end

  def to_xml
    ('<?xml version="1.0" encoding="UTF-8"?>'.dup << Ox.dump(wrap_in_document, effort: :tolerant)).force_encoding('UTF-8')
  end

  private

  def wrap_in_document
    Ox::Document.new(version: '1.0').tap do |document|
      document << Ox::Element.new('rss').tap do |rss|
        rss['version']        = '2.0'
        rss['xmlns:webfeeds'] = 'http://webfeeds.org/rss/1.0'
        rss['xmlns:media']    = 'http://search.yahoo.com/mrss/'

        rss << @dsl.to_element
      end
    end
  end
end
