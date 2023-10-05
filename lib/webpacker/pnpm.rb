# frozen_string_literal: true

require 'webpacker/compiler'
require 'webpacker/webpack_runner'
require 'webpacker/dev_server_runner'

# Inspired from https://github.com/thearchitector/webpacker-pnpm
# We do not need to do anything related to Rake tasks, as we already do not use them

Webpacker::Compiler.class_eval do
  def default_watched_paths
    [
      *configured_paths,
      config.source_path_globbed,
      'pnpm-lock.yaml', 'package.json',
      'config/webpack/**/*'
    ].freeze
  end

  def configured_paths
    if config.respond_to?(:additional_paths_globbed)
      config.additional_paths_globbed
    else
      config.resolved_paths_globbed
    end
  end
end

Webpacker::WebpackRunner.class_eval do
  def run
    env = Webpacker::Compiler.env
    env['WEBPACKER_CONFIG'] = @webpacker_config

    cmd = if node_modules_bin_exist?
            ["#{@node_modules_bin_path}/webpack"]
          else
            %w(pnpm webpack)
          end

    cmd = ['node', '--inspect-brk'] + cmd if @argv.include?('--debug-webpacker')

    cmd += ['--config', @webpack_config] + @argv

    Dir.chdir(@app_path) do
      Kernel.exec(env, *cmd)
    end
  end
end

Webpacker::DevServerRunner.class_eval do
  def execute_cmd
    env = Webpacker::Compiler.env
    env['WEBPACKER_CONFIG'] = @webpacker_config

    cmd = if node_modules_bin_exist?
            ["#{@node_modules_bin_path}/webpack-dev-server"]
          else
            %w(pnpm webpack-dev-server)
          end

    cmd = ['node', '--inspect-brk'] + cmd if @argv.include?('--debug-webpacker')

    cmd += ['--config', @webpack_config]
    cmd += ['--progress', '--color'] if @pretty

    Dir.chdir(@app_path) do
      Kernel.exec env, *cmd
    end
  end
end
