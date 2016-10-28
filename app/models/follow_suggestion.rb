class FollowSuggestion
  class << self
    def get(for_account_id, limit = 10)
      neo = Neography::Rest.new

      query = <<END
START a=node:account_index(Account={id})
MATCH (a)-[:follows]->(b)-[:follows]->(c)
WHERE a <> c
AND NOT (a)-[:follows]->(c)
RETURN DISTINCT c.account_id, count(b), c.nodeRank
ORDER BY count(b) DESC, c.nodeRank DESC
LIMIT {limit}
END

      results = neo.execute_query(query, id: for_account_id, limit: limit)

      if results.empty? || results['data'].empty?
        results = fallback(for_account_id, limit)
      elsif results['data'].size < limit
        results['data'] = (results['data'] + fallback(for_account_id, limit - results['data'].size)['data']).uniq
      end

      account_ids  = results['data'].map(&:first)
      blocked_ids  = Block.where(account_id: for_account_id).pluck(:target_account_id)
      accounts_map = Account.where(id: account_ids - blocked_ids).with_counters.map { |a| [a.id, a] }.to_h

      account_ids.map { |id| accounts_map[id] }.compact
    rescue Neography::NeographyError, Excon::Error::Socket => e
      Rails.logger.error e
      return []
    end

    private

    def fallback(for_account_id, limit)
      neo = Neography::Rest.new

      query = <<END
MATCH (b)
WHERE b.account_id <> {id}
RETURN b.account_id
ORDER BY b.nodeRank DESC
LIMIT {limit}
END

      neo.execute_query(query, id: for_account_id, limit: limit)
    end
  end
end
