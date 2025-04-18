class StatusTree < ActiveModelSerializers::Model
  include PreloadingConcern

  MAX_COUNT = 4_096

  attributes :status, :account, :tree

  class Node < ActiveModelSerializers::Model
    attributes :status, :tree

    delegate :id, to: :status

    delegate_missing_to :status

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

    def ==(other)
      other.class.in?([Node, Status]) && id == other.id
    end

    def inspect
      "#<StatusTree::Node id: #{id}, in_reply_to_id: #{in_reply_to_id || 'nil'}>"
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

  def status_node
    find_node(status.id)
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
    in_reply_to_id = node.in_reply_to_id

    while in_reply_to_id
      parent_node = find_node(in_reply_to_id)
      break unless parent_node
      ancestors << parent_node
      in_reply_to_id = parent_node.in_reply_to_id
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

  def build_tree_from(nodes, in_reply_to_id = nil)
    grouped_nodes = nodes.group_by(&:in_reply_to_id)

    (grouped_nodes[in_reply_to_id] || []).each_with_object({}) do |node, tree|
      tree[node] = build_tree_from(nodes - [node], node.id)
    end
  end

  def descendants_max_depth
    nil
  end

  def descendants_max_count
    MAX_COUNT
  end

  def ancestors_max_count
    MAX_COUNT
  end

  def collect_descendants(subtree)
    subtree.flat_map do |node, children|
      [node] + collect_descendants(children)
    end
  end  
end
