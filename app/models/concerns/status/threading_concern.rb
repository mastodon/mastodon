# frozen_string_literal: true

module Status::ThreadingConcern
  extend ActiveSupport::Concern

  class_methods do
    def permitted_statuses_from_ids(ids, account, stable: false)
      statuses    = Status.with_accounts(ids).to_a
      account_ids = statuses.map(&:account_id).uniq
      domains     = statuses.filter_map(&:account_domain).uniq

      account&.preload_relations!(account_ids, domains)

      statuses.reject! { |status| StatusFilter.new(status, account).filtered? }

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

  def descendants(limit, account = nil, depth = nil)
    find_statuses_from_tree_path(descendant_ids(limit, depth), account, promote: true)
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
    Status.find_by_sql([<<~SQL.squish, id: in_reply_to_id, limit: limit])
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

  def descendant_ids(limit, depth)
    # use limit + 1 and depth + 1 because 'self' is included
    depth += 1 if depth.present?
    limit += 1 if limit.present?

    descendants_with_self = Status.find_by_sql([<<~SQL.squish, id: id, limit: limit, depth: depth])
      WITH RECURSIVE search_tree(id, path) AS (
        SELECT id, ARRAY[id]
        FROM statuses
        WHERE id = :id
      UNION ALL
        SELECT statuses.id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.in_reply_to_id = search_tree.id
        WHERE COALESCE(array_length(path, 1) < :depth, TRUE) AND NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path
      LIMIT :limit
    SQL

    descendants_with_self.pluck(:id) - [id]
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
