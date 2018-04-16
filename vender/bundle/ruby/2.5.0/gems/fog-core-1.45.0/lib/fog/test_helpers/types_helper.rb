# Format related hackery
# allows both true.is_a?(Fog::Boolean) and false.is_a?(Fog::Boolean)
# allows both nil.is_a?(Fog::Nullable::String) and ''.is_a?(Fog::Nullable::String)
module Fog
  module Boolean; end
  module Nullable
    module Boolean; end
    module Integer; end
    module String; end
    module Time; end
    module Float; end
    module Hash; end
    module Array; end
  end
end

[FalseClass, TrueClass].each {|klass| klass.send(:include, Fog::Boolean)}
[FalseClass, TrueClass, NilClass, Fog::Boolean].each {|klass| klass.send(:include, Fog::Nullable::Boolean)}
[NilClass, String].each {|klass| klass.send(:include, Fog::Nullable::String)}
[NilClass, Time].each {|klass| klass.send(:include, Fog::Nullable::Time)}
[Integer, NilClass].each {|klass| klass.send(:include, Fog::Nullable::Integer)}
[Float, NilClass].each {|klass| klass.send(:include, Fog::Nullable::Float)}
[Hash, NilClass].each {|klass| klass.send(:include, Fog::Nullable::Hash)}
[Array, NilClass].each {|klass| klass.send(:include, Fog::Nullable::Array)}
