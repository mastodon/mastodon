# frozen_string_literal: true

module Status::ThreadingConcern
  extend ActiveSupport::Concern

  class_methods do
    def permitted_statuses_from_ids(ids, account, stable: false)
      statuses    = Status.with_accounts(ids).to_a
      account_ids = statuses.map(&:account_id).uniq
      domains     = statuses.filter_map(&:account_domain).uniq
      relations   = account&.relations_map(account_ids, domains) || {}

      statuses.reject! { |status| StatusFilter.new(status, account, relations).filtered? }

      if stable
        statuses.sort_by! { |status| ids.index(status.id) }
      else
        statuses
      end
    end
  end

  def ancestors(limit, account = nil)
    find_statuses_from_tree_path(ancestor_ids(limit), account)
  end

  def descendants(account, limit:, depth:, after_id:)
    tree = descendant_ids(limit:, depth:, after_id:)

    statuses_map = Status.with_accounts(tree.reject { |id_or_placeholder| id_or_placeholder.is_a?(Context::Gap) }).index_by(&:id)
    account_ids = statuses_map.values.map(&:account_id).uniq
    domains = statuses_map.values.filter_map(&:account_domain).uniq
    relations = account&.relations_map(account_ids, domains) || {}

    statuses_map.values.each do |status|
      statuses_map[status.id] = Context::FilterGap.new(id: status.id) if StatusFilter.new(status, account, relations).filtered?
    end

    tree.map do |id_or_placeholder|
      if id_or_placeholder.is_a?(Context::Gap)
        id_or_placeholder
      else
        statuses_map[id_or_placeholder]
      end
    end
  end

  def self_replies(limit)
    account.statuses.distributable_visibility.where(in_reply_to_id: id).reorder(id: :asc).limit(limit)
  end

  private

  def ancestor_ids(limit)
    key = "ancestors:#{id}"
    ancestors = Rails.cache.fetch(key)

    if ancestors.nil? || ancestors[:limit] < limit
      ids = ancestor_statuses(limit).pluck(:id).reverse!
      Rails.cache.write key, limit: limit, ids: ids
      ids
    else
      ancestors[:ids].last(limit)
    end
  end

  def ancestor_statuses(limit)
    Status.find_by_sql([<<-SQL.squish, id: in_reply_to_id, limit: limit])
      WITH RECURSIVE search_tree(id, in_reply_to_id, path)
      AS (
        SELECT id, in_reply_to_id, ARRAY[id]
        FROM statuses
        WHERE id = :id
        UNION ALL
        SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.id = search_tree.in_reply_to_id
        WHERE NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path
      LIMIT :limit
    SQL
  end

  def descendant_ids(after_id:, limit:, depth:)
    # We also fetch nodes that are one level deeper than requested so we can create pagination markers
    descendant_leaves = Status.find_by_sql([<<-SQL.squish, id: id, after_id: after_id || 0, account_id: account_id, limit: limit, depth: depth])
      WITH RECURSIVE search_tree(id, account_id, path) AS (
        (
          SELECT statuses.id, statuses.account_id, ARRAY[statuses.id]
          FROM statuses
          WHERE statuses.in_reply_to_id = :id
            AND statuses.id > :after_id
          LIMIT :limit + 1
        )
      UNION ALL
        SELECT statuses.id, statuses.account_id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.in_reply_to_id = search_tree.id
        WHERE array_length(path, 1) < :depth + 1 AND NOT statuses.id = ANY(path)
      )
      SELECT id, path
      FROM search_tree
      ORDER BY CASE WHEN account_id = :account_id THEN 1 ELSE 0 END DESC, path ASC
    SQL

    current_top_level_leaf = nil
    top_level_leaves = 0
    past_cut_off = false

    descendant_leaves.filter_map do |result|
      if result.path.size == 1
        if top_level_leaves == limit
          past_cut_off = true
          next Context::LimitGap.new(id: current_top_level_leaf.id)
        end

        current_top_level_leaf = result
        top_level_leaves += 1
      end

      if past_cut_off
        nil
      elsif result.path.size > depth # Nodes that are deeper than requested are pagination markers
        Context::DepthGap.new(id: result.path[result.path.size - 2])
      else
        result.id
      end
    end
  end

  def find_statuses_from_tree_path(ids, account, promote: false)
    statuses = Status.permitted_statuses_from_ids(ids, account, stable: true)

    # Bring self-replies to the top
    if promote
      promote_by!(statuses) { |status| status.in_reply_to_account_id == status.account_id }
    else
      statuses
    end
  end

  def promote_by!(arr)
    insert_at = arr.find_index { |item| !yield(item) }

    return arr if insert_at.nil?

    arr.each_with_index do |item, index|
      next if index <= insert_at || !yield(item)

      arr.insert(insert_at, arr.delete_at(index))
      insert_at += 1
    end

    arr
  end
end
