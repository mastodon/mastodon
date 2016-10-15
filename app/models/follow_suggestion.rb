class FollowSuggestion
  def self.get(for_account_id)
    neo = Neography::Rest.new
    account_ids = neo.execute_query('START a=node:account_index(Account={id}) MATCH (a)-[:follows]->(b)-[:follows]->(c) WHERE a <> c AND NOT (a)-[:follows]->(c) RETURN DISTINCT c.account_id', id: for_account_id)
    Account.where(id: account_ids['data'].first) unless account_ids.empty?
  rescue Neography::NeographyError, Excon::Error::Socket => e
    Rails.logger.error e
    []
  end
end
