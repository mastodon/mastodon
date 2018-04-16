# external core dependencies
require "base64"
require "cgi"
require "uri"
require "excon"
require "fileutils"
require "formatador"
require "openssl"
require "time"
require "timeout"
require "ipaddr"

# internal core dependencies
require File.expand_path('../core/version', __FILE__)

# Mixins
require File.expand_path('../core/services_mixin', __FILE__)

require File.expand_path('../core/attributes', __FILE__)
require File.expand_path('../core/attributes/default', __FILE__)
require File.expand_path('../core/attributes/array', __FILE__)
require File.expand_path('../core/attributes/boolean', __FILE__)
require File.expand_path('../core/attributes/float', __FILE__)
require File.expand_path('../core/attributes/integer', __FILE__)
require File.expand_path('../core/attributes/string', __FILE__)
require File.expand_path('../core/attributes/time', __FILE__)
require File.expand_path('../core/attributes/timestamp', __FILE__)
require File.expand_path('../core/associations/default', __FILE__)
require File.expand_path('../core/associations/many_identities', __FILE__)
require File.expand_path('../core/associations/many_models', __FILE__)
require File.expand_path('../core/associations/one_model', __FILE__)
require File.expand_path('../core/associations/one_identity', __FILE__)
require File.expand_path('../core/collection', __FILE__)
require File.expand_path('../core/association', __FILE__)
require File.expand_path('../core/connection', __FILE__)
require File.expand_path('../core/credentials', __FILE__)
require File.expand_path('../core/current_machine', __FILE__)
require File.expand_path('../core/deprecation', __FILE__)
require File.expand_path('../core/errors', __FILE__)
require File.expand_path('../core/hmac', __FILE__)
require File.expand_path('../core/logger', __FILE__)
require File.expand_path('../core/model', __FILE__)
require File.expand_path('../core/mock', __FILE__)
require File.expand_path('../core/provider', __FILE__)
require File.expand_path('../core/service', __FILE__)
require File.expand_path('../core/ssh', __FILE__)
require File.expand_path('../core/scp', __FILE__)
require File.expand_path('../core/time', __FILE__)
require File.expand_path('../core/utils', __FILE__)
require File.expand_path('../core/wait_for', __FILE__)
require File.expand_path('../core/wait_for_defaults', __FILE__)
require File.expand_path('../core/uuid', __FILE__)
require File.expand_path('../core/stringify_keys', __FILE__)
require File.expand_path('../core/whitelist_keys', __FILE__)

require File.expand_path('../account', __FILE__)
require File.expand_path('../baremetal', __FILE__)
require File.expand_path('../billing', __FILE__)
require File.expand_path('../cdn', __FILE__)
require File.expand_path('../compute', __FILE__)
require File.expand_path('../dns', __FILE__)
require File.expand_path('../identity', __FILE__)
require File.expand_path('../image', __FILE__)
require File.expand_path('../introspection', __FILE__)
require File.expand_path('../metering', __FILE__)
require File.expand_path('../monitoring', __FILE__)
require File.expand_path('../nfv', __FILE__)
require File.expand_path('../network', __FILE__)
require File.expand_path('../orchestration', __FILE__)
require File.expand_path('../storage', __FILE__)
require File.expand_path('../support', __FILE__)
require File.expand_path('../volume', __FILE__)
require File.expand_path('../vpn', __FILE__)


# Utility
require File.expand_path('../formatador', __FILE__)
