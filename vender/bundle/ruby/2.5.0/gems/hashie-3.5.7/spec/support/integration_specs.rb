# Generates the bundle command for running an integration test
#
# @param [String] integration the integration folder to run
# @param [String] command the command to run
# @return [String]
def integration_command(integration, command)
  "#{integration_gemfile(integration)} #{command}"
end

# Generates the Gemfile for an integration
#
# @param [String] integration the integration test name
# @return [String]
def integration_gemfile(integration)
  "BUNDLE_GEMFILE=#{integration_path(integration)}/Gemfile"
end

# Generates the path to the integration
#
# @param [String] integration the integration test name
# @return [String]
def integration_path(integration)
  "spec/integration/#{integration}"
end

# Runs all integration specs in their own environment
def run_all_integration_specs(handler: ->(_code) {}, logger: ->(_msg) {})
  Dir['spec/integration/*']
    .map { |directory| directory.split('/').last }
    .each do |integration|
      logger.call(%(Running "#{integration}" integration spec))
      system(integration_command(integration, 'bundle --quiet'))
      system(integration_command(integration, "bundle exec rspec #{integration_path(integration)}"))
      handler.call($CHILD_STATUS.exitstatus)
    end
end
