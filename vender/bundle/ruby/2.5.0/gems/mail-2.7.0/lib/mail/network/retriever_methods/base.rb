# encoding: utf-8
# frozen_string_literal: true

module Mail

  class Retriever

    # Get the oldest received email(s)
    #
    # Possible options:
    #   count: number of emails to retrieve. The default value is 1.
    #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #
    def first(options = {}, &block)
      options ||= {}
      options[:what] = :first
      options[:count] ||= 1
      find(options, &block)
    end
    
    # Get the most recent received email(s)
    #
    # Possible options:
    #   count: number of emails to retrieve. The default value is 1.
    #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #
    def last(options = {}, &block)
      options ||= {}
      options[:what] = :last
      options[:count] ||= 1
      find(options, &block)
    end
    
    # Get all emails.
    #
    # Possible options:
    #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #
    def all(options = {}, &block)
      options ||= {}
      options[:count] = :all
      find(options, &block)
    end

    # Find emails in the mailbox, and then deletes them. Without any options, the 
    # five last received emails are returned.
    #
    # Possible options:
    #   what:  last or first emails. The default is :first.
    #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #   count: number of emails to retrieve. The default value is 10. A value of 1 returns an
    #          instance of Message, not an array of Message instances.
    #   delete_after_find: flag for whether to delete each retreived email after find. Default
    #           is true. Call #find if you would like this to default to false.
    #
    def find_and_delete(options = {}, &block)
      options ||= {}
      options[:delete_after_find] ||= true
      find(options, &block)      
    end 

  end

end
