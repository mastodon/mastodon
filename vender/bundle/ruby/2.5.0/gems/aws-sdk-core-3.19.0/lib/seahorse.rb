require_relative 'seahorse/util'

# client

require_relative 'seahorse/client/block_io'
require_relative 'seahorse/client/configuration'
require_relative 'seahorse/client/handler'
require_relative 'seahorse/client/handler_builder'
require_relative 'seahorse/client/handler_list'
require_relative 'seahorse/client/handler_list_entry'
require_relative 'seahorse/client/managed_file'
require_relative 'seahorse/client/networking_error'
require_relative 'seahorse/client/plugin'
require_relative 'seahorse/client/plugin_list'
require_relative 'seahorse/client/request'
require_relative 'seahorse/client/request_context'
require_relative 'seahorse/client/response'

# client http

require_relative 'seahorse/client/http/headers'
require_relative 'seahorse/client/http/request'
require_relative 'seahorse/client/http/response'

# client logging

require_relative 'seahorse/client/logging/handler'
require_relative 'seahorse/client/logging/formatter'

# net http handler

require_relative 'seahorse/client/net_http/connection_pool'
require_relative 'seahorse/client/net_http/handler'

# plugins

require_relative 'seahorse/client/plugins/content_length'
require_relative 'seahorse/client/plugins/endpoint'
require_relative 'seahorse/client/plugins/logging'
require_relative 'seahorse/client/plugins/net_http'
require_relative 'seahorse/client/plugins/raise_response_errors'
require_relative 'seahorse/client/plugins/response_target'

# model

require_relative 'seahorse/model/api'
require_relative 'seahorse/model/operation'
require_relative 'seahorse/model/authorizer'
require_relative 'seahorse/model/shapes'

require_relative 'seahorse/client/base'
