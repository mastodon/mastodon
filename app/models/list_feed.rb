class ListFeed < Feed
  def initialize(list)
    super(:list, list.id)
  end
end
