# -*- ruby -*-
#encoding: utf-8

# Warn about use of deprecated constants when this is autoloaded
callsite = caller(3).first

warn <<END_OF_WARNING
The PGconn, PGresult, and PGError constants are deprecated, and will be
removed as of version 1.0.

You should use PG::Connection, PG::Result, and PG::Error instead, respectively.

Called from #{callsite}
END_OF_WARNING



PGconn   = PG::Connection
PGresult = PG::Result
PGError  = PG::Error

