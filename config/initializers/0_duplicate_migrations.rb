ALLOWED_DUPLICATES = [20180410220657, 20180831171112].freeze

module ActiveRecord
  class Migrator
    old_initialize = instance_method(:initialize)

    define_method(:initialize) do |direction, migrations, target_version|
      migrated = Set.new(Base.connection.migration_context.get_all_versions)

      migrations.group_by(&:name).each do |name, duplicates|
        if duplicates.length > 1 && duplicates.all? { |m| ALLOWED_DUPLICATES.include?(m.version) }
          # We have a set of allowed duplicates. Keep the migrated one, if any.
          non_migrated = duplicates.reject { |m| migrated.include?(m.version.to_i) }

          if duplicates.length == non_migrated.length
            # There weren't any migrated one, so we have to pick one “canonical” migration
            migrations = migrations - duplicates[1..-1]
          else
            # Just reject every duplicate which hasn't been migrated yet
            migrations = migrations - non_migrated
          end
        end
      end

      old_initialize.bind(self).(direction, migrations, target_version)
    end
  end
end
