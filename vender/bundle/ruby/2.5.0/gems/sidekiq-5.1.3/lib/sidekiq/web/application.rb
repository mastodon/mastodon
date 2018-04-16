# frozen_string_literal: true

module Sidekiq
  class WebApplication
    extend WebRouter

    CONTENT_LENGTH = "Content-Length"
    CONTENT_TYPE = "Content-Type"
    REDIS_KEYS = %w(redis_version uptime_in_days connected_clients used_memory_human used_memory_peak_human)

    def initialize(klass)
      @klass = klass
    end

    def settings
      @klass.settings
    end

    def self.settings
      Sidekiq::Web.settings
    end

    def self.tabs
      Sidekiq::Web.tabs
    end

    def self.set(key, val)
      # nothing, backwards compatibility
    end

    get "/" do
      @redis_info = redis_info.select{ |k, v| REDIS_KEYS.include? k }
      stats_history = Sidekiq::Stats::History.new((params['days'] || 30).to_i)
      @processed_history = stats_history.processed
      @failed_history = stats_history.failed

      erb(:dashboard)
    end

    get "/busy" do
      erb(:busy)
    end

    post "/busy" do
      if params['identity']
        p = Sidekiq::Process.new('identity' => params['identity'])
        p.quiet! if params['quiet']
        p.stop! if params['stop']
      else
        processes.each do |pro|
          pro.quiet! if params['quiet']
          pro.stop! if params['stop']
        end
      end

      redirect "#{root_path}busy"
    end

    get "/queues" do
      @queues = Sidekiq::Queue.all

      erb(:queues)
    end

    get "/queues/:name" do
      @name = route_params[:name]

      halt(404) unless @name

      @count = (params['count'] || 25).to_i
      @queue = Sidekiq::Queue.new(@name)
      (@current_page, @total_size, @messages) = page("queue:#{@name}", params['page'], @count)
      @messages = @messages.map { |msg| Sidekiq::Job.new(msg, @name) }

      erb(:queue)
    end

    post "/queues/:name" do
      Sidekiq::Queue.new(route_params[:name]).clear

      redirect "#{root_path}queues"
    end

    post "/queues/:name/delete" do
      name = route_params[:name]
      Sidekiq::Job.new(params['key_val'], name).delete

      redirect_with_query("#{root_path}queues/#{CGI.escape(name)}")
    end

    get '/morgue' do
      @count = (params['count'] || 25).to_i
      (@current_page, @total_size, @dead) = page("dead", params['page'], @count, reverse: true)
      @dead = @dead.map { |msg, score| Sidekiq::SortedEntry.new(nil, score, msg) }

      erb(:morgue)
    end

    get "/morgue/:key" do
      halt(404) unless key = route_params[:key]

      @dead = Sidekiq::DeadSet.new.fetch(*parse_params(key)).first

      if @dead.nil?
        redirect "#{root_path}morgue"
      else
        erb(:dead)
      end
    end

    post '/morgue' do
      redirect(request.path) unless params['key']

      params['key'].each do |key|
        job = Sidekiq::DeadSet.new.fetch(*parse_params(key)).first
        retry_or_delete_or_kill job, params if job
      end

      redirect_with_query("#{root_path}morgue")
    end

    post "/morgue/all/delete" do
      Sidekiq::DeadSet.new.clear

      redirect "#{root_path}morgue"
    end

    post "/morgue/all/retry" do
      Sidekiq::DeadSet.new.retry_all

      redirect "#{root_path}morgue"
    end

    post "/morgue/:key" do
      halt(404) unless key = route_params[:key]

      job = Sidekiq::DeadSet.new.fetch(*parse_params(key)).first
      retry_or_delete_or_kill job, params if job

      redirect_with_query("#{root_path}morgue")
    end

    get '/retries' do
      @count = (params['count'] || 25).to_i
      (@current_page, @total_size, @retries) = page("retry", params['page'], @count)
      @retries = @retries.map { |msg, score| Sidekiq::SortedEntry.new(nil, score, msg) }

      erb(:retries)
    end

    get "/retries/:key" do
      @retry = Sidekiq::RetrySet.new.fetch(*parse_params(route_params[:key])).first

      if @retry.nil?
        redirect "#{root_path}retries"
      else
        erb(:retry)
      end
    end

    post '/retries' do
      redirect(request.path) unless params['key']

      params['key'].each do |key|
        job = Sidekiq::RetrySet.new.fetch(*parse_params(key)).first
        retry_or_delete_or_kill job, params if job
      end

      redirect_with_query("#{root_path}retries")
    end

    post "/retries/all/delete" do
      Sidekiq::RetrySet.new.clear

      redirect "#{root_path}retries"
    end

    post "/retries/all/retry" do
      Sidekiq::RetrySet.new.retry_all

      redirect "#{root_path}retries"
    end

    post "/retries/:key" do
      job = Sidekiq::RetrySet.new.fetch(*parse_params(route_params[:key])).first

      retry_or_delete_or_kill job, params if job

      redirect_with_query("#{root_path}retries")
    end

    get '/scheduled' do
      @count = (params['count'] || 25).to_i
      (@current_page, @total_size, @scheduled) = page("schedule", params['page'], @count)
      @scheduled = @scheduled.map { |msg, score| Sidekiq::SortedEntry.new(nil, score, msg) }

      erb(:scheduled)
    end

    get "/scheduled/:key" do
      @job = Sidekiq::ScheduledSet.new.fetch(*parse_params(route_params[:key])).first

      if @job.nil?
        redirect "#{root_path}scheduled"
      else
        erb(:scheduled_job_info)
      end
    end

    post '/scheduled' do
      redirect(request.path) unless params['key']

      params['key'].each do |key|
        job = Sidekiq::ScheduledSet.new.fetch(*parse_params(key)).first
        delete_or_add_queue job, params if job
      end

      redirect_with_query("#{root_path}scheduled")
    end

    post "/scheduled/:key" do
      halt(404) unless key = route_params[:key]

      job = Sidekiq::ScheduledSet.new.fetch(*parse_params(key)).first
      delete_or_add_queue job, params if job

      redirect_with_query("#{root_path}scheduled")
    end

    get '/dashboard/stats' do
      redirect "#{root_path}stats"
    end

    get '/stats' do
      sidekiq_stats = Sidekiq::Stats.new
      redis_stats   = redis_info.select { |k, v| REDIS_KEYS.include? k }
      json(
        sidekiq: {
          processed:       sidekiq_stats.processed,
          failed:          sidekiq_stats.failed,
          busy:            sidekiq_stats.workers_size,
          processes:       sidekiq_stats.processes_size,
          enqueued:        sidekiq_stats.enqueued,
          scheduled:       sidekiq_stats.scheduled_size,
          retries:         sidekiq_stats.retry_size,
          dead:            sidekiq_stats.dead_size,
          default_latency: sidekiq_stats.default_queue_latency
        },
        redis: redis_stats,
        server_utc_time: server_utc_time
      )
    end

    get '/stats/queues' do
      json Sidekiq::Stats::Queues.new.lengths
    end

    def call(env)
      action = self.class.match(env)
      return [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass" }, ["Not Found"]] unless action

      resp = catch(:halt) do
        app = @klass
        self.class.run_befores(app, action)
        begin
          resp = action.instance_exec env, &action.block
        ensure
          self.class.run_afters(app, action)
        end

        resp
      end

      resp = case resp
      when Array
        resp
      else
        headers = {
          "Content-Type" => "text/html",
          "Cache-Control" => "no-cache",
          "Content-Language" => action.locale,
        }

        [200, headers, [resp]]
      end

      resp[1] = resp[1].dup

      resp[1][CONTENT_LENGTH] = resp[2].inject(0) { |l, p| l + p.bytesize }.to_s

      resp
    end

    def self.helpers(mod=nil, &block)
      if block_given?
        WebAction.class_eval(&block)
      else
        WebAction.send(:include, mod)
      end
    end

    def self.before(path=nil, &block)
      befores << [path && Regexp.new("\\A#{path.gsub("*", ".*")}\\z"), block]
    end

    def self.after(path=nil, &block)
      afters << [path && Regexp.new("\\A#{path.gsub("*", ".*")}\\z"), block]
    end

    def self.run_befores(app, action)
      run_hooks(befores, app, action)
    end

    def self.run_afters(app, action)
      run_hooks(afters, app, action)
    end

    def self.run_hooks(hooks, app, action)
      hooks.select { |p,_| !p || p =~ action.env[WebRouter::PATH_INFO] }.
            each {|_,b| action.instance_exec(action.env, app, &b) }
    end

    def self.befores
      @befores ||= []
    end

    def self.afters
      @afters ||= []
    end
  end
end
