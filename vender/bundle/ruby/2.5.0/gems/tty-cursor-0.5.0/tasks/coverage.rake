# encoding: utf-8

desc 'Measure code coverage'
task :coverage do
  begin
    original, ENV['COVERAGE'] = ENV['COVERAGE'], 'true'
    Rake::Task['spec'].invoke
  ensure
    ENV['COVERAGE'] = original
  end
end
