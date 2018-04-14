require_relative "application"

Rails.backtrace_cleaner.remove_silencers!
Rails.application.initialize!
