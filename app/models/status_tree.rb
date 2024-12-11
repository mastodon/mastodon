class StatusTree < ActiveModelSerializers::Model
  include PreloadingConcern

  # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  MAX_COUNT = 4_096

  # This remains expensive and we don't want to show everything to logged-out users
  ANCESTORS_MAX_COUNT   = 40
  DESCENDANTS_MAX_COUNT = 60
  DESCENDANTS_MAX_DEPTH = 20  

  attributes :status, :account, :tree

  class Node < ActiveModelSerializers::Model
    attributes :status, :tree

    delegate_missing_to :status

    delegate :id, to: :status

    def object_type = :status

    def ancestors
      tree.ancestors_for(id)
    end

    def descendants
      tree.descendants_for(id)
    end

    def children
      tree.children_for(id)
    end

    def replies_count
      children.size
    end

    def ==(other)
      other.class.in?([Node, Status]) && id == other.id
    end

    def inspect
      "#<StatusTree::Node id: #{id}, parent_id: #{in_reply_to_id || 'nil'}>"
    end
  end

  def tree
    @tree ||= begin
      ancestors = preload_collection(status.in_reply_to_id.nil? ? [] : status.ancestors(ancestors_max_count, account), Status)
      descendants = preload_collection(status.descendants(descendants_max_count, account, descendants_max_depth), Status)
      all_nodes = (ancestors + [status] + descendants).map { |status| Node.new(status:, tree: self) }
      build_tree_from(all_nodes)
    end
  end

  def subtree_for(id, subtree = tree)
    subtree.each do |node, children|
      return children if node.id == id

      found = subtree_for(id, children)
      return found if found
    end
    nil
  end

  def flatten
    collect_descendants(tree)
  end

  delegate :each, :flat_map, :keys, to: :tree

  def inspect
    "#<StatusTree #{tree.inspect}>"
  end

  def find_node(id, subtree = tree)
    subtree.each do |node, children|
      return node if node.id == id
  
      result = find_node(id, children)
      return result if result
    end
  end

  def ancestors_for(id)
    ancestors = []
    node = find_node(id)
    parent_id = node.in_reply_to_id

    while parent_id
      parent_node = find_node(parent_id)
      break unless parent_node
      ancestors << parent_node
      parent_id = parent_node.in_reply_to_id
    end

    ancestors.reverse
  end

  def descendants_for(id)
    subtree = subtree_for(id)
    return [] unless subtree

    collect_descendants(subtree)
  end

  def children_for(id)
    subtree = subtree_for(id)

    subtree.keys
  end

  private

  def build_tree_from(nodes, parent_id = nil)
    grouped_nodes = nodes.group_by(&:in_reply_to_id)

    (grouped_nodes[parent_id] || []).each_with_object({}) do |node, tree|
      tree[node] = build_tree_from(nodes - [node], node.id)
    end
  end

  def descendants_max_depth
    account.nil? ? DESCENDANTS_MAX_DEPTH : nil
  end

  def descendants_max_count
    account.nil? ? DESCENDANTS_MAX_COUNT : MAX_COUNT
  end

  def ancestors_max_count
    account.nil? ? ANCESTORS_MAX_COUNT : MAX_COUNT
  end

  def collect_descendants(subtree)
    subtree.flat_map do |node, children|
      [node] + collect_descendants(children)
    end
  end  
end
