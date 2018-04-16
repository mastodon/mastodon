# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

require 'aws-sdk-core'
require 'aws-sigv4'

require_relative 'aws-sdk-kms/types'
require_relative 'aws-sdk-kms/client_api'
require_relative 'aws-sdk-kms/client'
require_relative 'aws-sdk-kms/errors'
require_relative 'aws-sdk-kms/resource'
require_relative 'aws-sdk-kms/customizations'

# This module provides support for AWS Key Management Service. This module is available in the
# `aws-sdk-kms` gem.
#
# # Client
#
# The {Client} class provides one method for each API operation. Operation
# methods each accept a hash of request parameters and return a response
# structure.
#
# See {Client} for more information.
#
# # Errors
#
# Errors returned from AWS Key Management Service all
# extend {Errors::ServiceError}.
#
#     begin
#       # do stuff
#     rescue Aws::KMS::Errors::ServiceError
#       # rescues all service API errors
#     end
#
# See {Errors} for more information.
#
# @service
module Aws::KMS

  GEM_VERSION = '1.5.0'

end
