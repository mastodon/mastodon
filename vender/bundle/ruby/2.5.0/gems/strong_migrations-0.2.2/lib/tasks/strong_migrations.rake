# http://nithinbekal.com/posts/safe-rake-tasks

namespace :strong_migrations do
  task safety_assured: :environment do
    raise "Set SAFETY_ASSURED=1 to run this task in production" if Rails.env.production? && !ENV["SAFETY_ASSURED"]
  end

  # https://www.pgrs.net/2008/03/13/alphabetize-schema-rb-columns/
  task :alphabetize_columns do
    $stderr.puts "Dumping schema"
    ActiveRecord::Base.logger.level = Logger::INFO

    class << ActiveRecord::Base.connection
      alias_method :old_columns, :columns unless instance_methods.include?("old_columns")
      alias_method :old_extensions, :extensions unless instance_methods.include?("old_extensions")

      def columns(*args)
        old_columns(*args).sort_by(&:name)
      end

      def extensions(*args)
        old_extensions(*args).sort
      end
    end
  end
end

["db:drop", "db:reset", "db:schema:load", "db:structure:load"].each do |t|
  Rake::Task[t].enhance ["strong_migrations:safety_assured"]
end
