# Test helper class to provide minitest hooks for Chewy::Index testing.
#
# @note Intended to be used in conjunction with a test helper which mocks over the #bulk
#   method on a {Chewy::Type} class. (See SearchTestHelper)
#
# The class will capture the data from the *param on the Chewy::Type.bulk method and
# aggregate the data for test analysis.
class SearchIndexReceiver
  def initialize
    @mutations = {}
  end

  # @param bulk_params [Hash] the bulk_params that should be sent to the Chewy::Type.bulk method.
  # @param type [Chewy::Type] the type executing this query.
  def catch(bulk_params, type)
    Array.wrap(bulk_params).map { |y| y[:body] }.flatten.each do |update|
      if update[:delete]
        mutation_for(type).deletes << update[:delete][:_id]
      elsif update[:index]
        mutation_for(type).indexes << update[:index]
      end
    end
  end

  # @param index [Chewy::Index] return only index requests to the specified {Chewy::Type} index.
  # @return [Hash] the index changes captured by the mock.
  def indexes_for(index = nil)
    if index
      mutation_for(index).indexes
    else
      Hash[
        @mutations.map { |a, b| [a, b.indexes] }
      ]
    end
  end
  alias_method :indexes, :indexes_for

  # @param index [Chewy::Index] return only delete requests to the specified {Chewy::Type} index.
  # @return [Hash] the index deletes captured by the mock.
  def deletes_for(index = nil)
    if index
      mutation_for(index).deletes
    else
      Hash[
        @mutations.map { |a, b| [a, b.deletes] }
      ]
    end
  end
  alias_method :deletes, :deletes_for

  # Check to see if a given object has been indexed.
  # @param obj [#id] obj the object to look for.
  # @param type [Chewy::Type] what type the object should be indexed as.
  # @return [true, false] if the object was indexed.
  def indexed?(obj, type)
    indexes_for(type).map { |i| i[:_id] }.include? obj.id
  end

  # Check to see if a given object has been deleted.
  # @param obj [#id] obj the object to look for.
  # @param type [Chewy::Type] what type the object should have been deleted from.
  # @return [true, false] if the object was deleted.
  def deleted?(obj, type)
    deletes_for(type).include? obj.id
  end

  # @return [Array<Chewy::Type>] a list of types indexes changed.
  def updated_indexes
    @mutations.keys
  end

private

  # Get the mutation object for a given type.
  # @param type [Chewy::Type] the index type to fetch.
  # @return [#indexes, #deletes] an object with a list of indexes and a list of deletes.
  def mutation_for(type)
    @mutations[type] ||= OpenStruct.new(indexes: [], deletes: [])
  end
end
