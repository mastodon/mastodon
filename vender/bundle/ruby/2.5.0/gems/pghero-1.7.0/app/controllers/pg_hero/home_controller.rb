module PgHero
  class HomeController < ActionController::Base
    layout "pg_hero/application"

    protect_from_forgery

    http_basic_authenticate_with name: ENV["PGHERO_USERNAME"], password: ENV["PGHERO_PASSWORD"] if ENV["PGHERO_PASSWORD"]

    if respond_to?(:before_action)
      before_action :set_database
      before_action :set_query_stats_enabled
    else
      before_filter :set_database
      before_filter :set_query_stats_enabled
    end

    def index
      @title = "Overview"
      @extended = params[:extended]
      @query_stats = @database.query_stats(historical: true, start_at: 3.hours.ago)
      @slow_queries = @database.slow_queries(query_stats: @query_stats)
      @autovacuum_queries, @long_running_queries = @database.long_running_queries.partition { |q| q["query"].starts_with?("autovacuum:") }

      if @extended
        @index_hit_rate = @database.index_hit_rate
        @table_hit_rate = @database.table_hit_rate
        @good_cache_rate = @table_hit_rate >= @database.cache_hit_rate_threshold.to_f / 100 && @index_hit_rate >= @database.cache_hit_rate_threshold.to_f / 100
      end

      @unused_indexes = @database.unused_indexes.select { |q| q["index_scans"].to_i == 0 } if @extended
      @invalid_indexes = @database.invalid_indexes
      @duplicate_indexes = @database.duplicate_indexes
      unless @query_stats_enabled
        @query_stats_available = @database.query_stats_available?
        @query_stats_extension_enabled = @database.query_stats_extension_enabled? if @query_stats_available
      end
      @total_connections = @database.total_connections
      @good_total_connections = @total_connections < @database.total_connections_threshold
      if @replica
        @replication_lag = @database.replication_lag
        @good_replication_lag = @replication_lag < 5
      end
      @transaction_id_danger = @database.transaction_id_danger(threshold: 1500000000)
      set_suggested_indexes((params[:min_average_time] || 20).to_f, (params[:min_calls] || 50).to_i)
      @show_migrations = PgHero.show_migrations
      @sequence_danger = @database.sequence_danger(threshold: params[:sequence_threshold])
    end

    def index_usage
      @title = "Index Usage"
      @index_usage = @database.index_usage
    end

    def space
      @title = "Space"
      @database_size = @database.database_size
      @relation_sizes = @database.relation_sizes
    end

    def live_queries
      @title = "Live Queries"
      @running_queries = @database.running_queries
    end

    def queries
      @title = "Queries"
      @historical_query_stats_enabled = @database.historical_query_stats_enabled?
      @sort = %w(average_time calls).include?(params[:sort]) ? params[:sort] : nil
      @min_average_time = params[:min_average_time] ? params[:min_average_time].to_i : nil
      @min_calls = params[:min_calls] ? params[:min_calls].to_i : nil

      @query_stats =
        begin
          if @historical_query_stats_enabled
            @start_at = params[:start_at] ? Time.zone.parse(params[:start_at]) : 24.hours.ago
            @end_at = Time.zone.parse(params[:end_at]) if params[:end_at]
          end

          if @historical_query_stats_enabled && !request.xhr?
            []
          else
            @database.query_stats(
              historical: true,
              start_at: @start_at,
              end_at: @end_at,
              sort: @sort,
              min_average_time: @min_average_time,
              min_calls: @min_calls
            )
          end
        rescue
          @error = true
          []
        end

      set_suggested_indexes

      # fix back button issue with caching
      response.headers["Cache-Control"] = "must-revalidate, no-store, no-cache, private"
      if request.xhr?
        render layout: false, partial: "queries_table", locals: {queries: @query_stats, xhr: true}
      end
    end

    def system
      @title = "System"
      @periods = {
        "1 hour" => {duration: 1.hour, period: 60.seconds},
        "1 day" => {duration: 1.day, period: 10.minutes},
        "1 week" => {duration: 1.week, period: 30.minutes},
        "2 weeks" => {duration: 2.weeks, period: 1.hours}
      }
    end

    def cpu_usage
      render json: [{name: "CPU", data: @database.cpu_usage(system_params).map { |k, v| [k, v.round] }, library: chart_library_options}]
    end

    def connection_stats
      render json: [{name: "Connections", data: @database.connection_stats(system_params), library: chart_library_options}]
    end

    def replication_lag_stats
      render json: [{name: "Lag", data: @database.replication_lag_stats(system_params), library: chart_library_options}]
    end

    def load_stats
      render json: [
        {name: "Read IOPS", data: @database.read_iops_stats(system_params).map { |k, v| [k, v.round] }, library: chart_library_options},
        {name: "Write IOPS", data: @database.write_iops_stats(system_params).map { |k, v| [k, v.round] }, library: chart_library_options}
      ]
    end

    def explain
      @title = "Explain"
      @query = params[:query]
      # TODO use get + token instead of post so users can share links
      # need to prevent CSRF and DoS
      if request.post? && @query
        begin
          prefix =
            case params[:commit]
            when "Analyze"
              "ANALYZE "
            when "Visualize"
              "(ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON) "
            else
              ""
            end
          @explanation = @database.explain("#{prefix}#{@query}")
          @suggested_index = @database.suggested_indexes(queries: [@query]).first
          @visualize = params[:commit] == "Visualize"
        rescue ActiveRecord::StatementInvalid => e
          @error = e.message
        end
      end
    end

    def tune
      @title = "Tune"
      @settings = @database.settings
    end

    def connections
      @title = "Connections"
      @total_connections = @database.total_connections
      @connection_sources = @database.connection_sources(by_database_and_user: true)
    end

    def maintenance
      @title = "Maintenance"
      @maintenance_info = @database.maintenance_info
      @time_zone = PgHero.time_zone
    end

    def kill
      if @database.kill(params[:pid])
        redirect_to root_path, notice: "Query killed"
      else
        redirect_backward notice: "Query no longer running"
      end
    end

    def kill_long_running_queries
      @database.kill_long_running_queries
      redirect_backward notice: "Queries killed"
    end

    def kill_all
      @database.kill_all
      redirect_backward notice: "Connections killed"
    end

    def enable_query_stats
      @database.enable_query_stats
      redirect_backward notice: "Query stats enabled"
    rescue ActiveRecord::StatementInvalid
      redirect_backward alert: "The database user does not have permission to enable query stats"
    end

    def reset_query_stats
      @database.reset_query_stats
      redirect_backward notice: "Query stats reset"
    rescue ActiveRecord::StatementInvalid
      redirect_backward alert: "The database user does not have permission to reset query stats"
    end

    protected

    def redirect_backward(options = {})
      if Rails.version >= "5.1"
        redirect_back options.merge(fallback_location: root_path)
      else
        redirect_to :back, options
      end
    end

    def set_database
      @databases = PgHero.databases.values
      if params[:database]
        @database = PgHero.databases[params[:database]]
      elsif @databases.size > 1
        redirect_to url_for(controller: controller_name, action: action_name, database: @databases.first.id)
      else
        @database = @databases.first
      end
    end

    def default_url_options
      {database: params[:database]}
    end

    def set_query_stats_enabled
      @query_stats_enabled = @database.query_stats_enabled?
      @system_stats_enabled = @database.system_stats_enabled?
      @replica = @database.replica?
    end

    def set_suggested_indexes(min_average_time = 0, min_calls = 0)
      @suggested_indexes_by_query = @database.suggested_indexes_by_query(query_stats: @query_stats.select { |qs| qs["average_time"].to_f >= min_average_time && qs["calls"].to_i >= min_calls })
      @suggested_indexes = @database.suggested_indexes(suggested_indexes_by_query: @suggested_indexes_by_query)
      @query_stats_by_query = @query_stats.index_by { |q| q["query"] }
      @debug = params[:debug] == "true"
    end

    def system_params
      params.permit(:duration, :period)
    end

    def chart_library_options
      {pointRadius: 0, pointHitRadius: 5, borderWidth: 4}
    end
  end
end
