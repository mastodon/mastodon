module Hiredis
  begin
    require "hiredis/ext/connection"
    Connection = Ext::Connection
  rescue LoadError
    warn "WARNING: could not load hiredis extension, using (slower) pure Ruby implementation."
    require "hiredis/ruby/connection"
    Connection = Ruby::Connection
  end
end
