# frozen_string_literal: true

class ListFeed < Feed
  def initialize(list)
    @type    = :list
    @id      = list.id
  end
end
