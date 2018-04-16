all_benchamrk_tasks = []

namespace(:benchmark) do
  
  Dir[File.join(File.dirname(__FILE__), '..', 'benchmarks', '*_benchmark.rb')]. each do |benchmark_file|
    task_name = File.basename(benchmark_file, '_benchmark.rb').to_sym
    
    desc "Run the #{task_name} benchmark."
    task(task_name, :n) do |task, args|
      ENV['N'] = args[:n] if args[:n]
      load(File.expand_path(benchmark_file))
    end
    
    all_benchamrk_tasks << "benchmark:#{task_name}"
  end
end

unless all_benchamrk_tasks.empty?
  desc 'Run the whole benchmark suite'
  task(:benchmark, :n) do |task, args|
    all_benchamrk_tasks.each do |t| 
      task(t).invoke(args[:n])
      puts
    end
  end
end
