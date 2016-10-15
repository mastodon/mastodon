class FollowSuggestion
  def self.get(for_account_id, limit = 6)
    neo = Neography::Rest.new

    query = <<END
START a=node:account_index(Account={id})
MATCH (a)-[:follows]->(b)-[:follows]->(c)
WHERE a <> c
AND NOT (a)-[:follows]->(c)
RETURN DISTINCT c.account_id, c.nodeRank
ORDER BY c.nodeRank
LIMIT {limit}
END

    results = neo.execute_query(query, id: for_account_id, limit: limit)

    return fallback(for_account_id, limit) if results.empty?

    map_to_accounts(for_account_id, results)
  rescue Neography::NeographyError, Excon::Error::Socket => e
    Rails.logger.error e
    return []
  end

  private

  def self.fallback(for_account_id, limit)
    neo     = Neography::Rest.new
    query   = 'MATCH (a) WHERE a.account_id <> {id} RETURN a.account_id ORDER BY a.nodeRank DESC LIMIT {limit}'
    results = neo.execute_query(query, id: for_account_id, limit: limit)

    map_to_accounts(for_account_id, results)
  rescue Neography::NeographyError, Excon::Error::Socket => e
    Rails.logger.error e
    return []
  end

  def self.map_to_accounts(for_account_id, results)
    return [] if results.empty?

    account_ids  = results['data'].map(&:first)
    blocked_ids  = Block.where(account_id: for_account_id).pluck(:target_account_id)
    accounts_map = Account.where(id: account_ids - blocked_ids).map { |a| [a.id, a] }.to_h

    account_ids.map { |id| accounts_map[id] }.compact
  end
end
