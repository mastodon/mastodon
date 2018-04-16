# frozen_string_literal: true

module ServerRunner
  def run_server(name)
    let! name do
      server = yield

      Thread.new { server.start }

      server
    end

    after do
      send(name).shutdown
    end
  end
end

RSpec.configure { |c| c.extend ServerRunner }
