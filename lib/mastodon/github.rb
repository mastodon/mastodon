# frozen_string_literal: true

module Mastodon
  module Github
    module_function

    def host
      'https://github.com'
    end

    def author
      'imas'
    end

    def repository
      'mastodon'
    end

    def link_title
      [author, repository].join('/')
    end

    def to_s
      [host, author, repository].join('/')
    end
  end
end
