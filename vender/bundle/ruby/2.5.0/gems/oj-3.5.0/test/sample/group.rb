
module Sample
  class Group
    attr_reader :members
    
    def initialize()
      @members = []
    end
    
    def <<(member)
      @members << member
    end

  end # Group
end # Sample
    
