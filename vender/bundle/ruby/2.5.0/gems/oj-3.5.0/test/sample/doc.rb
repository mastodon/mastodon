
require 'sample/hasprops'
require 'sample/group'
require 'sample/layer'
require 'sample/line'
require 'sample/shape'
require 'sample/oval'
require 'sample/rect'
require 'sample/text'
require 'sample/change'

module Sample
  class Doc
    include HasProps
    
    attr_accessor :title
    attr_accessor :create_time
    attr_accessor :user
    # Hash of layers in the document indexed by layer name.
    attr_reader :layers
    attr_reader :change_history

    def initialize(title)
      @title = title
      @user = ENV['USER']
      @create_time = Time.now
      @layers = { }
      @change_history = []
    end
    
    def add_change(comment, time=nil, user=nil)
      @change_history << Change.new(comment, time, user)
    end

  end # Doc
end # Sample
