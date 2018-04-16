# encoding: utf-8
# frozen_string_literal: true
# 
# = Comments Field
# 
# The Comments field inherits from UnstructuredField and handles the Comments:
# header field in the email.
# 
# Sending comments to a mail message will instantiate a Mail::Field object that
# has a CommentsField as its field type.
#  
# An email header can have as many comments fields as it wants.  There is no upper
# limit, the comments field is also optional (that is, no comment is needed)
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.comments = 'This is a comment'
#  mail.comments    #=> 'This is a comment'
#  mail[:comments]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::CommentsField:0x180e1c4
#  mail['comments'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::CommentsField:0x180e1c4
#  mail['comments'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::CommentsField:0x180e1c4
# 
#  mail.comments = "This is another comment"
#  mail[:comments].map { |c| c.to_s } 
#  #=> ['This is a comment', "This is another comment"]
#
module Mail
  class CommentsField < UnstructuredField
    
    FIELD_NAME = 'comments'
    CAPITALIZED_FIELD = 'Comments'
    
    def initialize(value = nil, charset = 'utf-8')
      @charset = charset
      super(CAPITALIZED_FIELD, value)
      self.parse
      self
    end
    
  end
end
