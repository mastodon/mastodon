# frozen_string_literal: true

# TODO: https://github.com/simplecov-ruby/simplecov/pull/1084
# Patches this missing condition, monitor for upstream fix

module SimpleCov
  module SourceFileExtensions
    def build_branches
      coverage_branch_data = coverage_data.fetch('branches', {}) || {} # Add the final empty hash in case where 'branches' is present, but returns nil
      branches = coverage_branch_data.flat_map do |condition, coverage_branches|
        build_branches_from(condition, coverage_branches)
      end

      process_skipped_branches(branches)
    end
  end
end

SimpleCov::SourceFile.prepend(SimpleCov::SourceFileExtensions) if defined?(SimpleCov::SourceFile)
