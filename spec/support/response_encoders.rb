# frozen_string_literal: true

ActionDispatch::IntegrationTest
  .register_encoder :xml, response_parser: ->(body) { Nokogiri::XML(body) }
