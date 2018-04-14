# A Ruby library implementing OpenBSD's bcrypt()/crypt_blowfish algorithm for
# hashing passwords.
module BCrypt
end

if RUBY_PLATFORM == "java"
  require 'java'
else
  require "openssl"
end

begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require "#{$1}/bcrypt_ext"
rescue LoadError
  require "bcrypt_ext"
end

require 'bcrypt/error'
require 'bcrypt/engine'
require 'bcrypt/password'
