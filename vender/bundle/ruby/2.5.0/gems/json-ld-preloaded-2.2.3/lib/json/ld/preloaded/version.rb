# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD::Preloaded::VERSION
  VERSION_FILE = File.expand_path("../../../../../VERSION", __FILE__)
  MAJOR, MINOR, TINY, EXTRA = File.read(VERSION_FILE).chomp.split(".")

  STRING = [MAJOR, MINOR, TINY, EXTRA].compact.join('.')

  ##
  # @return [String]
  def self.to_s()   STRING end

  ##
  # @return [String]
  def self.to_str() STRING end

  ##
  # @return [Array(Integer, Integer, Integer)]
  def self.to_a() STRING.split(".") end
end
