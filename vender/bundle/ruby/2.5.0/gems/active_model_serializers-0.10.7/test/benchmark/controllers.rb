class PrimaryResourceController < ActionController::Base
  PRIMARY_RESOURCE =
    begin
      if ENV['BENCH_STRESS']
        has_many_relationships = (0..50).map do |i|
          HasManyRelationship.new(id: i, body: 'ZOMG A HAS MANY RELATIONSHIP')
        end
      else
        has_many_relationships = [HasManyRelationship.new(id: 1, body: 'ZOMG A HAS MANY RELATIONSHIP')]
      end
      has_one_relationship = HasOneRelationship.new(id: 42, first_name: 'Joao', last_name: 'Moura')
      PrimaryResource.new(id: 1337, title: 'New PrimaryResource', virtual_attribute: nil, body: 'Body', has_many_relationships: has_many_relationships, has_one_relationship: has_one_relationship)
    end

  def render_with_caching_serializer
    toggle_cache_status
    render json: PRIMARY_RESOURCE, serializer: CachingPrimaryResourceSerializer, adapter: :json, meta: { caching: perform_caching }
  end

  def render_with_fragment_caching_serializer
    toggle_cache_status
    render json: PRIMARY_RESOURCE, serializer: FragmentCachingPrimaryResourceSerializer, adapter: :json, meta: { caching: perform_caching }
  end

  def render_with_non_caching_serializer
    toggle_cache_status
    render json: PRIMARY_RESOURCE, adapter: :json, meta: { caching: perform_caching }
  end

  def render_cache_status
    toggle_cache_status
    # Uncomment to debug
    # STDERR.puts cache_store.class
    # STDERR.puts cache_dependencies
    # ActiveSupport::Cache::Store.logger.debug [ActiveModelSerializers.config.cache_store, ActiveModelSerializers.config.perform_caching, CachingPrimaryResourceSerializer._cache, perform_caching, params].inspect
    render json: { caching: perform_caching, meta: { cache_log: cache_messages, cache_status: cache_status } }.to_json
  end

  def clear
    ActionController::Base.cache_store.clear
    # Test caching is on
    # Uncomment to turn on logger; possible performance issue
    # logger = BenchmarkLogger.new
    # ActiveSupport::Cache::Store.logger = logger # seems to be the best way
    #
    # the below is used in some rails tests but isn't available/working in all versions, so far as I can tell
    # https://github.com/rails/rails/pull/15943
    # ActiveSupport::Notifications.subscribe(/^cache_(.*)\.active_support$/) do |*args|
    #   logger.debug ActiveSupport::Notifications::Event.new(*args)
    # end
    render json: 'ok'.to_json
  end

  private

  def cache_status
    {
      controller: perform_caching,
      app: Rails.configuration.action_controller.perform_caching,
      serializers: Rails.configuration.serializers.each_with_object({}) { |serializer, data| data[serializer.name] = serializer._cache.present? }
    }
  end

  def cache_messages
    ActiveSupport::Cache::Store.logger.is_a?(BenchmarkLogger) && ActiveSupport::Cache::Store.logger.messages.split("\n")
  end

  def toggle_cache_status
    case params[:on]
    when 'on'.freeze then self.perform_caching = true
    when 'off'.freeze then self.perform_caching = false
    else nil # no-op
    end
  end
end

Rails.application.routes.draw do
  get '/status(/:on)' => 'primary_resource#render_cache_status'
  get '/clear' => 'primary_resource#clear'
  get '/caching(/:on)' => 'primary_resource#render_with_caching_serializer'
  get '/fragment_caching(/:on)' => 'primary_resource#render_with_fragment_caching_serializer'
  get '/non_caching(/:on)' => 'primary_resource#render_with_non_caching_serializer'
end
