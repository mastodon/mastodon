
module Sample
  class Change
    attr_accessor :time
    attr_accessor :user
    attr_accessor :comment
    
    def initialize(comment=nil, time=nil, user=nil)
      @user = user || ENV['USER'] 
      @time = time || Time.now
      @comment = comment
    end
  end # Change
end # Sample
