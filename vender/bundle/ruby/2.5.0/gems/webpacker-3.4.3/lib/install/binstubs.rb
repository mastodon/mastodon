say "Copying binstubs"
directory "#{__dir__}/bin", "bin"

chmod "bin", 0755 & ~File.umask, verbose: false
