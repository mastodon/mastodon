# frozen_string_literal: true

require 'json'

module SidekiqUniqueJobs
  module Normalizer
    def self.jsonify(args)
      Sidekiq.load_json(Sidekiq.dump_json(args))
    end
  end
end
