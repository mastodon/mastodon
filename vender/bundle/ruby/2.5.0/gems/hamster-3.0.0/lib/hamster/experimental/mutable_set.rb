require "hamster/set"
require "hamster/read_copy_update"

module Hamster
  # @api private
  class MutableSet
    include ReadCopyUpdate

    def self.[](*items)
      MutableSet.new(Set[*items])
    end

    def add(item)
      transform { |set| set.add(item) }
    end
    alias :<< :add

    def add?(item)
      added = false
      transform do |set|
        added = !set.include?(item)
        set.add(item)
      end
      added
    end

    def delete(item)
      transform { |set| set.delete(item) }
    end

    def delete?(item)
      deleted = false
      transform do |set|
        deleted = set.include?(item)
        set.delete(item)
      end
      deleted
    end
  end
end
