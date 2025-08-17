# frozen_string_literal: true

# This file is entirely lifted from GitLab.

# The original file:
# https://gitlab.com/gitlab-org/gitlab/-/blob/69127d59467185cf4ff1109d88ceec1f499f354f/lib/gitlab/database.rb#L244-258

# Copyright (c) 2011-present GitLab B.V.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Mastodon
  module Database
    def self.add_post_migrate_path_to_rails(force: false)
      return if ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS'] && !force

      Rails.application.config.paths['db'].each do |db_path|
        path = Rails.root.join(db_path, 'post_migrate').to_s

        next if Rails.application.config.paths['db/migrate'].include?(path)

        Rails.application.config.paths['db/migrate'] << path

        # Rails memoizes migrations at certain points where it won't read the above
        # path just yet. As such we must also update the following list of paths.
        ActiveRecord::Migrator.migrations_paths << path
      end
    end
  end
end
