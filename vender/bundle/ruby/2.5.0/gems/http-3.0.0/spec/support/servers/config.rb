# frozen_string_literal: true

module ServerConfig
  def addr
    config[:BindAddress]
  end

  def port
    config[:Port]
  end
end
