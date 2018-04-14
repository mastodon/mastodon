# encoding: utf-8
# frozen_string_literal: true

module Mail

  class TestRetriever < Retriever

    def self.emails
      @@emails
    end

    def self.emails=(val)
      @@emails = val
    end

    def initialize(values)
      @@emails = []
    end

    def find(options = {}, &block)
      options[:count] ||= :all
      options[:order] ||= :asc
      options[:what] ||= :first
      emails_index = (0...@@emails.size).to_a
      emails_index.reverse! if options[:what] == :last
      emails_index = case count = options[:count]
        when :all then emails_index
        when Integer then emails_index[0, count]
        else
          raise 'Invalid count option value: ' + count.inspect
      end
      if options[:what] == :last && options[:order] == :asc || options[:what] == :first && options[:order] == :desc
        emails_index.reverse!
      end
      emails_index.each { |idx| @@emails[idx].mark_for_delete = true } if options[:delete_after_find]
      emails = emails_index.map { |idx| @@emails[idx] }
      emails.each { |email| yield email } if block_given?
      @@emails.reject!(&:is_marked_for_delete?) if options[:delete_after_find]
      emails.size == 1 && options[:count] == 1 ? emails.first : emails
    end

  end

end
