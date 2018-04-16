module Chewy
  class Index
    # Module provides per-index actions, such as deletion,
    # creation and existance check.
    #
    module Actions
      extend ActiveSupport::Concern

      module ClassMethods
        # Checks index existance. Returns true or false
        #
        #   UsersIndex.exists? #=> true
        #
        def exists?
          client.indices.exists(index: index_name)
        end

        # Creates index and applies mappings and settings.
        # Returns false in case of unsuccessful creation.
        #
        #   UsersIndex.create # creates index named `users`
        #
        # Index name suffix might be passed optionally. In this case,
        # method creates index with suffix and makes unsuffixed alias
        # for it.
        #
        #   UsersIndex.create '01-2013' # creates index `users_01-2013` and alias `users` for it
        #   UsersIndex.create '01-2013', alias: false # creates index `users_01-2013` only and no alias
        #
        # Suffixed index names might be used for zero-downtime mapping change, for example.
        # Description: (http://www.elasticsearch.org/blog/changing-mapping-with-zero-downtime/).
        #
        def create(*args)
          create!(*args)
        rescue Elasticsearch::Transport::Transport::Errors::BadRequest
          false
        end

        # Creates index and applies mappings and settings.
        # Raises elasticsearch-ruby transport error in case of
        # unsuccessfull creation.
        #
        #   UsersIndex.create! # creates index named `users`
        #
        # Index name suffix might be passed optionally. In this case,
        # method creates index with suffix and makes unsuffixed alias
        # for it.
        #
        #   UsersIndex.create! '01-2014' # creates index `users_01-2014` and alias `users` for it
        #   UsersIndex.create! '01-2014', alias: false # creates index `users_01-2014` only and no alias
        #
        # Suffixed index names might be used for zero-downtime mapping change, for example.
        # Description: (http://www.elasticsearch.org/blog/changing-mapping-with-zero-downtime/).
        #
        def create!(suffix = nil, **options)
          options.reverse_merge!(alias: true)
          general_name = index_name
          suffixed_name = index_name(suffix: suffix)

          body = specification_hash
          body[:aliases] = {general_name => {}} if options[:alias] && suffixed_name != general_name
          result = client.indices.create(index: suffixed_name, body: body)

          Chewy.wait_for_status if result
          result
        end

        # Deletes ES index. Returns false in case of error.
        #
        #   UsersIndex.delete # deletes `users` index
        #
        # Supports index suffix passed as the first argument
        #
        #   UsersIndex.delete '01-2014' # deletes `users_01-2014` index
        #
        def delete(suffix = nil)
          result = client.indices.delete index: index_name(suffix: suffix)
          Chewy.wait_for_status if result
          result
          # es-ruby >= 1.0.10 handles Elasticsearch::Transport::Transport::Errors::NotFound
          # by itself, rescue is for previous versions
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          false
        end

        # Deletes ES index. Raises elasticsearch-ruby transport error
        # in case of error.
        #
        #   UsersIndex.delete # deletes `users` index
        #
        # Supports index suffix passed as the first argument
        #
        #   UsersIndex.delete '01-2014' # deletes `users_01-2014` index
        #
        def delete!(suffix = nil)
          # es-ruby >= 1.0.10 handles Elasticsearch::Transport::Transport::Errors::NotFound
          # by itself, so it is raised here
          delete(suffix) or raise Elasticsearch::Transport::Transport::Errors::NotFound
        end

        # Deletes and recreates index. Supports suffixes.
        # Returns result of index creation.
        #
        #   UsersIndex.purge # deletes and creates `users` index
        #   UsersIndex.purge '01-2014' # deletes `users` and `users_01-2014` indexes, creates `users_01-2014`
        #
        def purge(suffix = nil)
          delete if suffix.present?
          delete suffix
          create suffix
        end

        # Deletes and recreates index. Supports suffixes.
        # Returns result of index creation. Raises error in case
        # of unsuccessfull creation
        #
        #   UsersIndex.purge! # deletes and creates `users` index
        #   UsersIndex.purge! '01-2014' # deletes `users` and `users_01-2014` indexes, creates `users_01-2014`
        #
        def purge!(suffix = nil)
          delete if suffix.present? && exists?
          delete suffix
          create! suffix
        end

        # Perform import operation for every defined type
        #
        #   UsersIndex.import                           # imports default data for every index type
        #   UsersIndex.import user: User.active         # imports specified objects for user type and default data for other types
        #   UsersIndex.import refresh: false            # to disable index refreshing after import
        #   UsersIndex.import suffix: Time.now.to_i     # imports data to index with specified suffix if such is exists
        #   UsersIndex.import batch_size: 300           # import batch size
        #
        # See [import.rb](lib/chewy/type/import.rb) for more details.
        #
        %i[import import!].each do |method|
          class_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{method}(*args)
              options = args.extract_options!
              if args.one? && type_names.one?
                objects = {type_names.first.to_sym => args.first}
              elsif args.one?
                fail ArgumentError, "Please pass objects for `#{method}` as a hash with type names"
              else
                objects = options.reject { |k, v| !type_names.map(&:to_sym).include?(k) }
              end
              types.map do |type|
                args = [objects[type.type_name.to_sym], options.dup].reject(&:blank?)
                type.#{method} *args
              end.all?
            end
          METHOD
        end

        # Deletes, creates and imports data to the index. Returns the
        # import result. If index name suffix is passed as the first
        # argument - performs zero-downtime index resetting.
        #
        # It also applies journal if anything was journaled during the
        # reset.
        #
        # @example
        #   UsersIndex.reset!
        #   UsersIndex.reset! Time.now.to_i
        #
        # @see http://www.elasticsearch.org/blog/changing-mapping-with-zero-downtime
        # @param suffix [String] a suffix for the newly created index
        # @param apply_journal [true, false] if true, journal is applied after the import is completed
        # @param journal [true, false] journaling is switched off for import during reset by default
        # @param import_options [Hash] options, passed to the import call
        # @return [true, false] false in case of errors
        def reset!(suffix = nil, apply_journal: true, journal: false, **import_options)
          result = if suffix.present?
            start_time = Time.now
            indexes = self.indexes
            create! suffix, alias: false

            general_name = index_name
            suffixed_name = index_name(suffix: suffix)

            optimize_index_settings suffixed_name
            result = import import_options.merge(suffix: suffix, journal: journal, refresh: !Chewy.reset_disable_refresh_interval)
            original_index_settings suffixed_name

            delete if indexes.blank?
            client.indices.update_aliases body: {actions: [
              *indexes.map do |index|
                {remove: {index: index, alias: general_name}}
              end,
              {add: {index: suffixed_name, alias: general_name}}
            ]}
            client.indices.delete index: indexes if indexes.present?

            self.journal.apply(start_time, **import_options) if apply_journal
            result
          else
            purge!
            import import_options.merge(journal: journal)
          end

          specification.lock!
          result
        end

        # A {Chewy::Journal} instance for the particular index
        #
        # @return [Chewy::Journal] journal instance
        def journal
          @journal ||= Chewy::Journal.new(self)
        end

      private

        def optimize_index_settings(index_name)
          settings = {}
          settings[:refresh_interval] = -1 if Chewy.reset_disable_refresh_interval
          settings[:number_of_replicas] = 0 if Chewy.reset_no_replicas
          update_settings index_name, settings: settings if settings.any?
        end

        def original_index_settings(index_name)
          settings = {}
          if Chewy.reset_disable_refresh_interval
            settings.merge! index_settings(:refresh_interval)
            settings[:refresh_interval] = '1s' if settings.empty?
          end
          settings.merge! index_settings(:number_of_replicas) if Chewy.reset_no_replicas
          update_settings index_name, settings: settings if settings.any?
        end

        def update_settings(index_name, **options)
          client.indices.put_settings index: index_name, body: {index: options[:settings]}
        end

        def index_settings(setting_name)
          return {} unless settings_hash.key?(:settings) && settings_hash[:settings].key?(:index)
          settings_hash[:settings][:index].slice(setting_name)
        end
      end
    end
  end
end
