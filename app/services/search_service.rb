class SearchService < BaseService
  def call(query, resolve = false)
    return if query.blank?

    username, domain = query.split('@')

    if domain.nil?
      search_all(username)
    else
      search_or_resolve(username, domain, resolve)
    end
  end

  private

  def search_all(username)
    Account.search_for(username)
  end

  def search_or_resolve(username, domain, resolve)
    results = Account.search_for("#{username} #{domain}")
    return [FollowRemoteAccountService.new.call("#{username}@#{domain}")] if results.empty? && resolve
    results
  end
end
