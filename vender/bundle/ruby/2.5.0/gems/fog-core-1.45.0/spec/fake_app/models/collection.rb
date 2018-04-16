require File.join(File.dirname(__FILE__), "model")

class Collection < Fog::Collection
  model Model
end