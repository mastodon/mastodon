# encoding: utf-8
# frozen_string_literal: true
module Mail
  class Part < Message
    
    # Creates a new empty Content-ID field and inserts it in the correct order
    # into the Header.  The ContentIdField object will automatically generate
    # a unique content ID if you try and encode it or output it to_s without
    # specifying a content id.
    # 
    # It will preserve the content ID you specify if you do.
    def add_content_id(content_id_val = '')
      header['content-id'] = content_id_val
    end
    
    # Returns true if the part has a content ID field, the field may or may
    # not have a value, but the field exists or not.
    def has_content_id?
      header.has_content_id?
    end
    
    def inline_content_id
      # TODO: Deprecated in 2.2.2 - Remove in 2.3
      warn("Part#inline_content_id is deprecated, please call Part#cid instead")
      cid
    end
    
    def cid
      add_content_id unless has_content_id?
      uri_escape(unbracket(content_id))
    end
    
    def url
      "cid:#{cid}"
    end
    
    def inline?
      header[:content_disposition].disposition_type == 'inline' if header[:content_disposition].respond_to?(:disposition_type)
    end
    
    def add_required_fields
      super
      add_content_id if !has_content_id? && inline?
    end

    def add_required_message_fields
      # Override so we don't add Date, MIME-Version, or Message-ID.
    end
    
    def delivery_status_report_part?
      (main_type =~ /message/i && sub_type =~ /delivery-status/i) && body =~ /Status:/
    end
    
    def delivery_status_data
      delivery_status_report_part? ? parse_delivery_status_report : {}
    end
    
    def bounced?
      if action.is_a?(Array)
        !!(action.first =~ /failed/i)
      else
        !!(action =~ /failed/i)
      end
    end
    
    
    # Either returns the action if the message has just a single report, or an
    # array of all the actions, one for each report
    def action
      get_return_values('action')
    end
    
    def final_recipient
      get_return_values('final-recipient')
    end
    
    def error_status
      get_return_values('status')
    end

    def diagnostic_code
      get_return_values('diagnostic-code')
    end
    
    def remote_mta
      get_return_values('remote-mta')
    end
    
    def retryable?
      !(error_status =~ /^5/)
    end

    private
    
    def get_return_values(key)
      if delivery_status_data[key].is_a?(Array)
        delivery_status_data[key].map { |a| a.value }
      elsif !delivery_status_data[key].nil?
        delivery_status_data[key].value
      else
        nil
      end
    end
    
    # A part may not have a header.... so, just init a body if no header
    def parse_message
      header_part, body_part = raw_source.split(/#{CRLF}#{WSP}*#{CRLF}/m, 2)
      if header_part =~ HEADER_LINE
        self.header = header_part
        self.body   = body_part
      else
        self.header = "Content-Type: text/plain\r\n"
        self.body   = raw_source
      end
    end
    
    def parse_delivery_status_report
      @delivery_status_data ||= Header.new(body.to_s.gsub("\r\n\r\n", "\r\n"))
    end

  end
  
end
