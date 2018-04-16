# frozen_string_literal: true

require "pathname"

module FixturesHelper
  def fixture(filename)
    fixtures_root.join filename
  end

  def fixtures_root
    @fixtures_root ||= Pathname.new(__FILE__).join("../../fixtures").realpath
  end
end
