module Hiredis
  begin
    require "hiredis/ext/reader"
    Reader = Ext::Reader
  rescue LoadError
    warn "WARNING: could not load hiredis extension, using (slower) pure Ruby implementation."
    require "hiredis/ruby/reader"
    Reader = Ruby::Reader
  end
end
