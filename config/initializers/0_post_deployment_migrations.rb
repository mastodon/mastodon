# frozen_string_literal: true

# Post deployment migrations are included by default. This file must be loaded
# before other initializers as Rails may otherwise memoize a list of migrations
# excluding the post deployment migrations.

Mastodon::Database.add_post_migrate_path_to_rails
