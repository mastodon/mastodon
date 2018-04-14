require 'open3'
require 'shellwords'

module Tilt
  # Standalone string interpolator and template processor implementation in Go.
  # see: https://github.com/gliderlabs/sigil
  class SigilTemplate < Template
    def prepare
    end

    def evaluate(scope, locals, &block)
      variables = locals.map {|k, v| "#{k}=#{v}" }

      cmd = ['sigil']

      unless variables.empty?
        cmd << '-p'
        cmd.concat(variables)
      end

      out, err, status = Open3.capture3(*cmd, :stdin_data => data)

      if status.success?
        out.chomp
      else
        raise err.chomp.gsub('<stdin>', file)
      end
    end

    def allows_script?
      false
    end
  end
end
