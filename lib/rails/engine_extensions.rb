module Rails
  module EngineExtensions
    # Rewrite task loading code to filter digitalocean.rake task
    def run_tasks_blocks(app)
      Railtie.instance_method(:run_tasks_blocks).bind(self).call(app)
      paths["lib/tasks"].existent.reject { |ext| ext.end_with?('digitalocean.rake') }.sort.each { |ext| load(ext) }
    end
  end
end

Rails::Engine.prepend(Rails::EngineExtensions)
