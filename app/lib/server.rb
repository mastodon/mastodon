# frozen_string_literal: true

class Server
  MAX_VERSION_REJECTS_LINK = Gem::Version.create('2.3.0')
  private_constant :MAX_VERSION_REJECTS_LINK

  def initialize(agent)
    matched = agent.match(/Mastodon\/([\.\d]*)/)
    @accepts_link = matched.nil? ? true : Gem::Version.create(matched[1]) > MAX_VERSION_REJECTS_LINK
  end

  def accepts_link?
    @accepts_link
  end
end
