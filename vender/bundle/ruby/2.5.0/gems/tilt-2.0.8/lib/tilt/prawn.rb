require 'tilt/template'
require 'prawn'

module Tilt
  # Prawn template implementation. See: http://prawnpdf.org
  #
  class PrawnTemplate < Template
    self.default_mime_type = 'application/pdf'
    
    def prepare
      @engine = ::Prawn::Document.new(prawn_options)
    end
    
    def evaluate(scope, locals, &block)
      pdf = @engine
      if data.respond_to?(:to_str)
        locals[:pdf] = pdf
        super(scope, locals, &block)
      elsif data.kind_of?(Proc)
        data.call(pdf)
      end
      @output ||= pdf.render
    end
    
    def allows_script?
      false
    end
    
    def precompiled_template(locals)
      data.to_str
    end
    
    
    private
      
      def prawn_options
        # defaults to A4 instead of crazy US Letter format. 
        { :page_size => "A4", :page_layout => :portrait }.merge(options)
      end
      
  end
  
end
