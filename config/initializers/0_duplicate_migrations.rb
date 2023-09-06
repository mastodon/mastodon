# frozen_string_literal: true

# Some migrations have been present in glitch-soc for a long time and have then
# been merged in upstream Mastodon, under a different version number.
#
# This puts us in an uneasy situation in which if we remove upstream's
# migration file, people migrating from upstream will end up having a conflict
# with their already-ran migration.
#
# On the other hand, if we keep upstream's migration and remove our own,
# any current glitch-soc user will have a conflict during migration.
#
# For lack of a better solution, as those migrations are indeed identical,
# we decided monkey-patching Rails' Migrator to completely ignore the duplicate,
# keeping only the one that has run, or an arbitrary one.

ALLOWED_DUPLICATES = [2018_04_10_220657, 2018_08_31_171112].freeze

module ActiveRecord
  class Migrator
    def self.new(direction, migrations, schema_migration, target_version = nil)
      migrated = Set.new(Base.connection.migration_context.get_all_versions)

      migrations.group_by(&:name).each do |_name, duplicates|
        next unless duplicates.length > 1 && duplicates.all? { |m| ALLOWED_DUPLICATES.include?(m.version) }

        # We have a set of allowed duplicates. Keep the migrated one, if any.
        non_migrated = duplicates.reject { |m| migrated.include?(m.version.to_i) }

        migrations = begin
          if duplicates.length == non_migrated.length || non_migrated.empty?
            # There weren't any migrated one, so we have to pick one “canonical” migration
            migrations - duplicates[1..]
          else
            # Just reject every duplicate which hasn't been migrated yet
            migrations - non_migrated
          end
        end
      end

      super(direction, migrations, schema_migration, target_version)
    end
  end

  class MigrationContext
    def needs_migration?
      # A set of duplicated migrations is considered migrated if at least one of
      # them is migrated.
      migrated = get_all_versions
      migrations.group_by(&:name).each do |_name, duplicates|
        return true unless duplicates.any? { |m| migrated.include?(m.version.to_i) }
      end
      false
    end
  end
end
