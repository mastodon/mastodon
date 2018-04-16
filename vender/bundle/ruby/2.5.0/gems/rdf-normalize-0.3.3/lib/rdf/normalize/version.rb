module RDF::Normalize::VERSION
  VERSION_FILE = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "VERSION")
  MAJOR, MINOR, TINY, EXTRA = File.read(VERSION_FILE).chop.split(".")

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
