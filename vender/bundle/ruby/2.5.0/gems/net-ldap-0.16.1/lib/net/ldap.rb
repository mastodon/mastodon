# -*- ruby encoding: utf-8 -*-
require 'ostruct'

module Net # :nodoc:
  class LDAP
    begin
      require 'openssl'
      ##
      # Set to +true+ if OpenSSL is available and LDAPS is supported.
      HasOpenSSL = true
    rescue LoadError
      # :stopdoc:
      HasOpenSSL = false
      # :startdoc:
    end
  end
end
require 'socket'

require 'net/ber'
require 'net/ldap/pdu'
require 'net/ldap/filter'
require 'net/ldap/dataset'
require 'net/ldap/password'
require 'net/ldap/entry'
require 'net/ldap/instrumentation'
require 'net/ldap/connection'
require 'net/ldap/version'
require 'net/ldap/error'
require 'net/ldap/auth_adapter'
require 'net/ldap/auth_adapter/simple'
require 'net/ldap/auth_adapter/sasl'

Net::LDAP::AuthAdapter.register([:simple, :anon, :anonymous], Net::LDAP::AuthAdapter::Simple)
Net::LDAP::AuthAdapter.register(:sasl, Net::LDAP::AuthAdapter::Sasl)

# == Quick-start for the Impatient
# === Quick Example of a user-authentication against an LDAP directory:
#
#  require 'rubygems'
#  require 'net/ldap'
#
#  ldap = Net::LDAP.new
#  ldap.host = your_server_ip_address
#  ldap.port = 389
#  ldap.auth "joe_user", "opensesame"
#  if ldap.bind
#    # authentication succeeded
#  else
#    # authentication failed
#  end
#
#
# === Quick Example of a search against an LDAP directory:
#
#  require 'rubygems'
#  require 'net/ldap'
#
#  ldap = Net::LDAP.new :host => server_ip_address,
#       :port => 389,
#       :auth => {
#             :method => :simple,
#             :username => "cn=manager, dc=example, dc=com",
#             :password => "opensesame"
#       }
#
#  filter = Net::LDAP::Filter.eq("cn", "George*")
#  treebase = "dc=example, dc=com"
#
#  ldap.search(:base => treebase, :filter => filter) do |entry|
#    puts "DN: #{entry.dn}"
#    entry.each do |attribute, values|
#      puts "   #{attribute}:"
#      values.each do |value|
#        puts "      --->#{value}"
#      end
#    end
#  end
#
#  p ldap.get_operation_result
#
# === Setting connect timeout
#
# By default, Net::LDAP uses TCP sockets with a connection timeout of 5 seconds.
#
# This value can be tweaked passing the :connect_timeout parameter.
# i.e.
#  ldap = Net::LDAP.new ...,
#                       :connect_timeout => 3
#
# == A Brief Introduction to LDAP
#
# We're going to provide a quick, informal introduction to LDAP terminology
# and typical operations. If you're comfortable with this material, skip
# ahead to "How to use Net::LDAP." If you want a more rigorous treatment of
# this material, we recommend you start with the various IETF and ITU
# standards that relate to LDAP.
#
# === Entities
# LDAP is an Internet-standard protocol used to access directory servers.
# The basic search unit is the <i>entity, </i> which corresponds to a person
# or other domain-specific object. A directory service which supports the
# LDAP protocol typically stores information about a number of entities.
#
# === Principals
# LDAP servers are typically used to access information about people, but
# also very often about such items as printers, computers, and other
# resources. To reflect this, LDAP uses the term <i>entity, </i> or less
# commonly, <i>principal, </i> to denote its basic data-storage unit.
#
# === Distinguished Names
# In LDAP's view of the world, an entity is uniquely identified by a
# globally-unique text string called a <i>Distinguished Name, </i> originally
# defined in the X.400 standards from which LDAP is ultimately derived. Much
# like a DNS hostname, a DN is a "flattened" text representation of a string
# of tree nodes. Also like DNS (and unlike Java package names), a DN
# expresses a chain of tree-nodes written from left to right in order from
# the most-resolved node to the most-general one.
#
# If you know the DN of a person or other entity, then you can query an
# LDAP-enabled directory for information (attributes) about the entity.
# Alternatively, you can query the directory for a list of DNs matching a
# set of criteria that you supply.
#
# === Attributes
#
# In the LDAP view of the world, a DN uniquely identifies an entity.
# Information about the entity is stored as a set of <i>Attributes.</i> An
# attribute is a text string which is associated with zero or more values.
# Most LDAP-enabled directories store a well-standardized range of
# attributes, and constrain their values according to standard rules.
#
# A good example of an attribute is <tt>sn, </tt> which stands for "Surname."
# This attribute is generally used to store a person's surname, or last
# name. Most directories enforce the standard convention that an entity's
# <tt>sn</tt> attribute have <i>exactly one</i> value. In LDAP jargon, that
# means that <tt>sn</tt> must be <i>present</i> and <i>single-valued.</i>
#
# Another attribute is <tt>mail, </tt> which is used to store email
# addresses. (No, there is no attribute called "email, " perhaps because
# X.400 terminology predates the invention of the term <i>email.</i>)
# <tt>mail</tt> differs from <tt>sn</tt> in that most directories permit any
# number of values for the <tt>mail</tt> attribute, including zero.
#
# === Tree-Base
# We said above that X.400 Distinguished Names are <i>globally unique.</i>
# In a manner reminiscent of DNS, LDAP supposes that each directory server
# contains authoritative attribute data for a set of DNs corresponding to a
# specific sub-tree of the (notional) global directory tree. This subtree is
# generally configured into a directory server when it is created. It
# matters for this discussion because most servers will not allow you to
# query them unless you specify a correct tree-base.
#
# Let's say you work for the engineering department of Big Company, Inc.,
# whose internet domain is bigcompany.com. You may find that your
# departmental directory is stored in a server with a defined tree-base of
#    ou=engineering, dc=bigcompany, dc=com
# You will need to supply this string as the <i>tree-base</i> when querying
# this directory. (Ou is a very old X.400 term meaning "organizational
# unit." Dc is a more recent term meaning "domain component.")
#
# === LDAP Versions
# (stub, discuss v2 and v3)
#
# === LDAP Operations
# The essential operations are: #bind, #search, #add, #modify, #delete, and
# #rename.
#
# ==== Bind
# #bind supplies a user's authentication credentials to a server, which in
# turn verifies or rejects them. There is a range of possibilities for
# credentials, but most directories support a simple username and password
# authentication.
#
# Taken by itself, #bind can be used to authenticate a user against
# information stored in a directory, for example to permit or deny access to
# some other resource. In terms of the other LDAP operations, most
# directories require a successful #bind to be performed before the other
# operations will be permitted. Some servers permit certain operations to be
# performed with an "anonymous" binding, meaning that no credentials are
# presented by the user. (We're glossing over a lot of platform-specific
# detail here.)
#
# ==== Search
# Calling #search against the directory involves specifying a treebase, a
# set of <i>search filters, </i> and a list of attribute values. The filters
# specify ranges of possible values for particular attributes. Multiple
# filters can be joined together with AND, OR, and NOT operators. A server
# will respond to a #search by returning a list of matching DNs together
# with a set of attribute values for each entity, depending on what
# attributes the search requested.
#
# ==== Add
# #add specifies a new DN and an initial set of attribute values. If the
# operation succeeds, a new entity with the corresponding DN and attributes
# is added to the directory.
#
# ==== Modify
# #modify specifies an entity DN, and a list of attribute operations.
# #modify is used to change the attribute values stored in the directory for
# a particular entity. #modify may add or delete attributes (which are lists
# of values) or it change attributes by adding to or deleting from their
# values. Net::LDAP provides three easier methods to modify an entry's
# attribute values: #add_attribute, #replace_attribute, and
# #delete_attribute.
#
# ==== Delete
# #delete specifies an entity DN. If it succeeds, the entity and all its
# attributes is removed from the directory.
#
# ==== Rename (or Modify RDN)
# #rename (or #modify_rdn) is an operation added to version 3 of the LDAP
# protocol. It responds to the often-arising need to change the DN of an
# entity without discarding its attribute values. In earlier LDAP versions,
# the only way to do this was to delete the whole entity and add it again
# with a different DN.
#
# #rename works by taking an "old" DN (the one to change) and a "new RDN, "
# which is the left-most part of the DN string. If successful, #rename
# changes the entity DN so that its left-most node corresponds to the new
# RDN given in the request. (RDN, or "relative distinguished name, " denotes
# a single tree-node as expressed in a DN, which is a chain of tree nodes.)
#
# == How to use Net::LDAP
# To access Net::LDAP functionality in your Ruby programs, start by
# requiring the library:
#
#  require 'net/ldap'
#
# If you installed the Gem version of Net::LDAP, and depending on your
# version of Ruby and rubygems, you _may_ also need to require rubygems
# explicitly:
#
#  require 'rubygems'
#  require 'net/ldap'
#
# Most operations with Net::LDAP start by instantiating a Net::LDAP object.
# The constructor for this object takes arguments specifying the network
# location (address and port) of the LDAP server, and also the binding
# (authentication) credentials, typically a username and password. Given an
# object of class Net:LDAP, you can then perform LDAP operations by calling
# instance methods on the object. These are documented with usage examples
# below.
#
# The Net::LDAP library is designed to be very disciplined about how it
# makes network connections to servers. This is different from many of the
# standard native-code libraries that are provided on most platforms, which
# share bloodlines with the original Netscape/Michigan LDAP client
# implementations. These libraries sought to insulate user code from the
# workings of the network. This is a good idea of course, but the practical
# effect has been confusing and many difficult bugs have been caused by the
# opacity of the native libraries, and their variable behavior across
# platforms.
#
# In general, Net::LDAP instance methods which invoke server operations make
# a connection to the server when the method is called. They execute the
# operation (typically binding first) and then disconnect from the server.
# The exception is Net::LDAP#open, which makes a connection to the server
# and then keeps it open while it executes a user-supplied block.
# Net::LDAP#open closes the connection on completion of the block.
class Net::LDAP
  include Net::LDAP::Instrumentation

  SearchScope_BaseObject = 0
  SearchScope_SingleLevel = 1
  SearchScope_WholeSubtree = 2
  SearchScopes = [SearchScope_BaseObject, SearchScope_SingleLevel,
    SearchScope_WholeSubtree]

  DerefAliases_Never = 0
  DerefAliases_Search = 1
  DerefAliases_Find = 2
  DerefAliases_Always = 3
  DerefAliasesArray = [DerefAliases_Never, DerefAliases_Search, DerefAliases_Find, DerefAliases_Always]

  primitive = { 2 => :null } # UnbindRequest body
  constructed = {
    0 => :array, # BindRequest
    1 => :array, # BindResponse
    2 => :array, # UnbindRequest
    3 => :array, # SearchRequest
    4 => :array, # SearchData
    5 => :array, # SearchResult
    6 => :array, # ModifyRequest
    7 => :array, # ModifyResponse
    8 => :array, # AddRequest
    9 => :array, # AddResponse
    10 => :array, # DelRequest
    11 => :array, # DelResponse
    12 => :array, # ModifyRdnRequest
    13 => :array, # ModifyRdnResponse
    14 => :array, # CompareRequest
    15 => :array, # CompareResponse
    16 => :array, # AbandonRequest
    19 => :array, # SearchResultReferral
    24 => :array, # Unsolicited Notification
  }
  application = {
    :primitive => primitive,
    :constructed => constructed,
  }
  primitive = {
    0 => :string, # password
    1 => :string, # Kerberos v4
    2 => :string, # Kerberos v5
    3 => :string, # SearchFilter-extensible
    4 => :string, # SearchFilter-extensible
    7 => :string, # serverSaslCreds
  }
  constructed = {
    0 => :array, # RFC-2251 Control and Filter-AND
    1 => :array, # SearchFilter-OR
    2 => :array, # SearchFilter-NOT
    3 => :array, # Seach referral
    4 => :array, # unknown use in Microsoft Outlook
    5 => :array, # SearchFilter-GE
    6 => :array, # SearchFilter-LE
    7 => :array, # serverSaslCreds
    9 => :array, # SearchFilter-extensible
  }
  context_specific = {
    :primitive => primitive,
    :constructed => constructed,
  }

  universal = {
    constructed: {
      107 => :array, #ExtendedResponse (PasswdModifyResponseValue)
    },
  }

  AsnSyntax = Net::BER.compile_syntax(:application => application,
                                      :universal => universal,
                                      :context_specific => context_specific)

  DefaultHost = "127.0.0.1"
  DefaultPort = 389
  DefaultAuth = { :method => :anonymous }
  DefaultTreebase = "dc=com"
  DefaultForceNoPage = false

  StartTlsOid = '1.3.6.1.4.1.1466.20037'
  PasswdModifyOid = '1.3.6.1.4.1.4203.1.11.1'

  # https://tools.ietf.org/html/rfc4511#section-4.1.9
  # https://tools.ietf.org/html/rfc4511#appendix-A
  ResultCodeSuccess                      = 0
  ResultCodeOperationsError              = 1
  ResultCodeProtocolError                = 2
  ResultCodeTimeLimitExceeded            = 3
  ResultCodeSizeLimitExceeded            = 4
  ResultCodeCompareFalse                 = 5
  ResultCodeCompareTrue                  = 6
  ResultCodeAuthMethodNotSupported       = 7
  ResultCodeStrongerAuthRequired         = 8
  ResultCodeReferral                     = 10
  ResultCodeAdminLimitExceeded           = 11
  ResultCodeUnavailableCriticalExtension = 12
  ResultCodeConfidentialityRequired      = 13
  ResultCodeSaslBindInProgress           = 14
  ResultCodeNoSuchAttribute              = 16
  ResultCodeUndefinedAttributeType       = 17
  ResultCodeInappropriateMatching        = 18
  ResultCodeConstraintViolation          = 19
  ResultCodeAttributeOrValueExists       = 20
  ResultCodeInvalidAttributeSyntax       = 21
  ResultCodeNoSuchObject                 = 32
  ResultCodeAliasProblem                 = 33
  ResultCodeInvalidDNSyntax              = 34
  ResultCodeAliasDereferencingProblem    = 36
  ResultCodeInappropriateAuthentication  = 48
  ResultCodeInvalidCredentials           = 49
  ResultCodeInsufficientAccessRights     = 50
  ResultCodeBusy                         = 51
  ResultCodeUnavailable                  = 52
  ResultCodeUnwillingToPerform           = 53
  ResultCodeNamingViolation              = 64
  ResultCodeObjectClassViolation         = 65
  ResultCodeNotAllowedOnNonLeaf          = 66
  ResultCodeNotAllowedOnRDN              = 67
  ResultCodeEntryAlreadyExists           = 68
  ResultCodeObjectClassModsProhibited    = 69
  ResultCodeAffectsMultipleDSAs          = 71
  ResultCodeOther                        = 80

  # https://tools.ietf.org/html/rfc4511#appendix-A.1
  ResultCodesNonError = [
    ResultCodeSuccess,
    ResultCodeCompareFalse,
    ResultCodeCompareTrue,
    ResultCodeReferral,
    ResultCodeSaslBindInProgress,
  ]

  # nonstandard list of "successful" result codes for searches
  ResultCodesSearchSuccess = [
    ResultCodeSuccess,
    ResultCodeTimeLimitExceeded,
    ResultCodeSizeLimitExceeded,
  ]

  # map of result code to human message
  ResultStrings = {
    ResultCodeSuccess                      => "Success",
    ResultCodeOperationsError              => "Operations Error",
    ResultCodeProtocolError                => "Protocol Error",
    ResultCodeTimeLimitExceeded            => "Time Limit Exceeded",
    ResultCodeSizeLimitExceeded            => "Size Limit Exceeded",
    ResultCodeCompareFalse                 => "False Comparison",
    ResultCodeCompareTrue                  => "True Comparison",
    ResultCodeAuthMethodNotSupported       => "Auth Method Not Supported",
    ResultCodeStrongerAuthRequired         => "Stronger Auth Needed",
    ResultCodeReferral                     => "Referral",
    ResultCodeAdminLimitExceeded           => "Admin Limit Exceeded",
    ResultCodeUnavailableCriticalExtension => "Unavailable crtical extension",
    ResultCodeConfidentialityRequired      => "Confidentiality Required",
    ResultCodeSaslBindInProgress           => "saslBindInProgress",
    ResultCodeNoSuchAttribute              => "No Such Attribute",
    ResultCodeUndefinedAttributeType       => "Undefined Attribute Type",
    ResultCodeInappropriateMatching        => "Inappropriate Matching",
    ResultCodeConstraintViolation          => "Constraint Violation",
    ResultCodeAttributeOrValueExists       => "Attribute or Value Exists",
    ResultCodeInvalidAttributeSyntax       => "Invalide Attribute Syntax",
    ResultCodeNoSuchObject                 => "No Such Object",
    ResultCodeAliasProblem                 => "Alias Problem",
    ResultCodeInvalidDNSyntax              => "Invalid DN Syntax",
    ResultCodeAliasDereferencingProblem    => "Alias Dereferencing Problem",
    ResultCodeInappropriateAuthentication  => "Inappropriate Authentication",
    ResultCodeInvalidCredentials           => "Invalid Credentials",
    ResultCodeInsufficientAccessRights     => "Insufficient Access Rights",
    ResultCodeBusy                         => "Busy",
    ResultCodeUnavailable                  => "Unavailable",
    ResultCodeUnwillingToPerform           => "Unwilling to perform",
    ResultCodeNamingViolation              => "Naming Violation",
    ResultCodeObjectClassViolation         => "Object Class Violation",
    ResultCodeNotAllowedOnNonLeaf          => "Not Allowed On Non-Leaf",
    ResultCodeNotAllowedOnRDN              => "Not Allowed On RDN",
    ResultCodeEntryAlreadyExists           => "Entry Already Exists",
    ResultCodeObjectClassModsProhibited    => "ObjectClass Modifications Prohibited",
    ResultCodeAffectsMultipleDSAs          => "Affects Multiple DSAs",
    ResultCodeOther                        => "Other",
  }

  module LDAPControls
    PAGED_RESULTS = "1.2.840.113556.1.4.319" # Microsoft evil from RFC 2696
    SORT_REQUEST  = "1.2.840.113556.1.4.473"
    SORT_RESPONSE = "1.2.840.113556.1.4.474"
    DELETE_TREE   = "1.2.840.113556.1.4.805"
  end

  def self.result2string(code) #:nodoc:
    ResultStrings[code] || "unknown result (#{code})"
  end

  attr_accessor :host
  attr_accessor :port
  attr_accessor :hosts
  attr_accessor :base

  # Instantiate an object of type Net::LDAP to perform directory operations.
  # This constructor takes a Hash containing arguments, all of which are
  # either optional or may be specified later with other methods as
  # described below. The following arguments are supported:
  # * :host => the LDAP server's IP-address (default 127.0.0.1)
  # * :port => the LDAP server's TCP port (default 389)
  # * :hosts => an enumerable of pairs of hosts and corresponding ports with
  #   which to attempt opening connections (default [[host, port]])
  # * :auth => a Hash containing authorization parameters. Currently
  #   supported values include: {:method => :anonymous} and {:method =>
  #   :simple, :username => your_user_name, :password => your_password }
  #   The password parameter may be a Proc that returns a String.
  # * :base => a default treebase parameter for searches performed against
  #   the LDAP server. If you don't give this value, then each call to
  #   #search must specify a treebase parameter. If you do give this value,
  #   then it will be used in subsequent calls to #search that do not
  #   specify a treebase. If you give a treebase value in any particular
  #   call to #search, that value will override any treebase value you give
  #   here.
  # * :force_no_page => Set to true to prevent paged results even if your
  #   server says it supports them. This is a fix for MS Active Directory
  # * :instrumentation_service => An object responsible for instrumenting
  #   operations, compatible with ActiveSupport::Notifications' public API.
  # * :encryption => specifies the encryption to be used in communicating
  #   with the LDAP server. The value must be a Hash containing additional
  #   parameters, which consists of two keys:
  #     method: - :simple_tls or :start_tls
  #     tls_options: - Hash of options for that method
  #   The :simple_tls encryption method encrypts <i>all</i> communications
  #   with the LDAP server. It completely establishes SSL/TLS encryption with
  #   the LDAP server before any LDAP-protocol data is exchanged. There is no
  #   plaintext negotiation and no special encryption-request controls are
  #   sent to the server. <i>The :simple_tls option is the simplest, easiest
  #   way to encrypt communications between Net::LDAP and LDAP servers.</i>
  #   If you get communications or protocol errors when using this option,
  #   check with your LDAP server administrator. Pay particular attention
  #   to the TCP port you are connecting to. It's impossible for an LDAP
  #   server to support plaintext LDAP communications and <i>simple TLS</i>
  #   connections on the same port. The standard TCP port for unencrypted
  #   LDAP connections is 389, but the standard port for simple-TLS
  #   encrypted connections is 636. Be sure you are using the correct port.
  #   The :start_tls like the :simple_tls encryption method also encrypts all
  #   communcations with the LDAP server. With the exception that it operates
  #   over the standard TCP port.
  #
  #   To validate the LDAP server's certificate (a security must if you're
  #   talking over the public internet), you need to set :tls_options
  #   something like this...
  #
  #   Net::LDAP.new(
  #     # ... set host, bind dn, etc ...
  #     encryption: {
  #       method: :simple_tls,
  #       tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
  #     }
  #   )
  #
  #   The above will use the operating system-provided store of CA
  #   certificates to validate your LDAP server's cert.
  #   If cert validation fails, it'll happen during the #bind
  #   whenever you first try to open a connection to the server.
  #   Those methods will throw Net::LDAP::ConnectionError with
  #   a message about certificate verify failing. If your
  #   LDAP server's certificate is signed by DigiCert, Comodo, etc.,
  #   you're probably good. If you've got a self-signed cert but it's
  #   been added to the host's OS-maintained CA store (e.g. on Debian
  #   add foobar.crt to /usr/local/share/ca-certificates/ and run
  #   `update-ca-certificates`), then the cert should pass validation.
  #   To ignore the OS's CA store, put your CA in a PEM-encoded file and...
  #
  #   encryption: {
  #     method:      :simple_tls,
  #     tls_options: { ca_file:     '/path/to/my-little-ca.pem',
  #                    ssl_version: 'TLSv1_1' },
  #   }
  #
  #   As you might guess, the above example also fails the connection
  #   if the client can't negotiate TLS v1.1.
  #   tls_options is ultimately passed to OpenSSL::SSL::SSLContext#set_params
  #   For more details, see
  #    http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/SSL/SSLContext.html
  #
  # Instantiating a Net::LDAP object does <i>not</i> result in network
  # traffic to the LDAP server. It simply stores the connection and binding
  # parameters in the object. That's why Net::LDAP.new doesn't throw
  # cert validation errors itself; #bind does instead.
  def initialize(args = {})
    @host = args[:host] || DefaultHost
    @port = args[:port] || DefaultPort
    @hosts = args[:hosts]
    @verbose = false # Make this configurable with a switch on the class.
    @auth = args[:auth] || DefaultAuth
    @base = args[:base] || DefaultTreebase
    @force_no_page = args[:force_no_page] || DefaultForceNoPage
    @encryption = normalize_encryption(args[:encryption]) # may be nil
    @connect_timeout = args[:connect_timeout]

    if pr = @auth[:password] and pr.respond_to?(:call)
      @auth[:password] = pr.call
    end

    @instrumentation_service = args[:instrumentation_service]

    # This variable is only set when we are created with LDAP::open. All of
    # our internal methods will connect using it, or else they will create
    # their own.
    @open_connection = nil
  end

  # Convenience method to specify authentication credentials to the LDAP
  # server. Currently supports simple authentication requiring a username
  # and password.
  #
  # Observe that on most LDAP servers, the username is a complete DN.
  # However, with A/D, it's often possible to give only a user-name rather
  # than a complete DN. In the latter case, beware that many A/D servers are
  # configured to permit anonymous (uncredentialled) binding, and will
  # silently accept your binding as anonymous if you give an unrecognized
  # username. This is not usually what you want. (See
  # #get_operation_result.)
  #
  # <b>Important:</b> The password argument may be a Proc that returns a
  # string. This makes it possible for you to write client programs that
  # solicit passwords from users or from other data sources without showing
  # them in your code or on command lines.
  #
  #  require 'net/ldap'
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = server_ip_address
  #  ldap.authenticate "cn=Your Username, cn=Users, dc=example, dc=com", "your_psw"
  #
  # Alternatively (with a password block):
  #
  #  require 'net/ldap'
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = server_ip_address
  #  psw = proc { your_psw_function }
  #  ldap.authenticate "cn=Your Username, cn=Users, dc=example, dc=com", psw
  #
  def authenticate(username, password)
    password = password.call if password.respond_to?(:call)
    @auth = {
      :method => :simple,
      :username => username,
      :password => password,
    }
  end
  alias_method :auth, :authenticate

  # Convenience method to specify encryption characteristics for connections
  # to LDAP servers. Called implicitly by #new and #open, but may also be
  # called by user code if desired. The single argument is generally a Hash
  # (but see below for convenience alternatives). This implementation is
  # currently a stub, supporting only a few encryption alternatives. As
  # additional capabilities are added, more configuration values will be
  # added here.
  #
  # This method is deprecated.
  #
  def encryption(args)
    warn "Deprecation warning: please give :encryption option as a Hash to Net::LDAP.new"
    return if args.nil?
    @encryption = normalize_encryption(args)
  end

  # #open takes the same parameters as #new. #open makes a network
  # connection to the LDAP server and then passes a newly-created Net::LDAP
  # object to the caller-supplied block. Within the block, you can call any
  # of the instance methods of Net::LDAP to perform operations against the
  # LDAP directory. #open will perform all the operations in the
  # user-supplied block on the same network connection, which will be closed
  # automatically when the block finishes.
  #
  #  # (PSEUDOCODE)
  #  auth = { :method => :simple, :username => username, :password => password }
  #  Net::LDAP.open(:host => ipaddress, :port => 389, :auth => auth) do |ldap|
  #    ldap.search(...)
  #    ldap.add(...)
  #    ldap.modify(...)
  #  end
  def self.open(args)
    ldap1 = new(args)
    ldap1.open { |ldap| yield ldap }
  end

  # Returns a meaningful result any time after a protocol operation (#bind,
  # #search, #add, #modify, #rename, #delete) has completed. It returns an
  # #OpenStruct containing an LDAP result code (0 means success), and a
  # human-readable string.
  #
  #  unless ldap.bind
  #    puts "Result: #{ldap.get_operation_result.code}"
  #    puts "Message: #{ldap.get_operation_result.message}"
  #  end
  #
  # Certain operations return additional information, accessible through
  # members of the object returned from #get_operation_result. Check
  # #get_operation_result.error_message and
  # #get_operation_result.matched_dn.
  #
  #--
  # Modified the implementation, 20Mar07. We might get a hash of LDAP
  # response codes instead of a simple numeric code.
  #++
  def get_operation_result
    result = @result
    os = OpenStruct.new
    if result.is_a?(Net::LDAP::PDU)
      os.extended_response = result.extended_response
      result = result.result
    end
    if result.is_a?(Hash)
      # We might get a hash of LDAP response codes instead of a simple
      # numeric code.
      os.code = (result[:resultCode] || "").to_i
      os.error_message = result[:errorMessage]
      os.matched_dn = result[:matchedDN]
    elsif result
      os.code = result
    else
      os.code = Net::LDAP::ResultCodeSuccess
    end
    os.message = Net::LDAP.result2string(os.code)
    os
  end

  # Opens a network connection to the server and then passes <tt>self</tt>
  # to the caller-supplied block. The connection is closed when the block
  # completes. Used for executing multiple LDAP operations without requiring
  # a separate network connection (and authentication) for each one.
  # <i>Note:</i> You do not need to log-in or "bind" to the server. This
  # will be done for you automatically. For an even simpler approach, see
  # the class method Net::LDAP#open.
  #
  #  # (PSEUDOCODE)
  #  auth = { :method => :simple, :username => username, :password => password }
  #  ldap = Net::LDAP.new(:host => ipaddress, :port => 389, :auth => auth)
  #  ldap.open do |ldap|
  #    ldap.search(...)
  #    ldap.add(...)
  #    ldap.modify(...)
  #  end
  def open
    # First we make a connection and then a binding, but we don't do
    # anything with the bind results. We then pass self to the caller's
    # block, where he will execute his LDAP operations. Of course they will
    # all generate auth failures if the bind was unsuccessful.
    raise Net::LDAP::AlreadyOpenedError, "Open already in progress" if @open_connection

    instrument "open.net_ldap" do |payload|
      begin
        @open_connection = new_connection
        payload[:connection] = @open_connection
        payload[:bind]       = @open_connection.bind(@auth)
        yield self
      ensure
        @open_connection.close if @open_connection
        @open_connection = nil
      end
    end
  end

  # Searches the LDAP directory for directory entries. Takes a hash argument
  # with parameters. Supported parameters include:
  # * :base (a string specifying the tree-base for the search);
  # * :filter (an object of type Net::LDAP::Filter, defaults to
  #   objectclass=*);
  # * :attributes (a string or array of strings specifying the LDAP
  #   attributes to return from the server);
  # * :return_result (a boolean specifying whether to return a result set).
  # * :attributes_only (a boolean flag, defaults false)
  # * :scope (one of: Net::LDAP::SearchScope_BaseObject,
  #   Net::LDAP::SearchScope_SingleLevel,
  #   Net::LDAP::SearchScope_WholeSubtree. Default is WholeSubtree.)
  # * :size (an integer indicating the maximum number of search entries to
  #   return. Default is zero, which signifies no limit.)
  # * :time (an integer restricting the maximum time in seconds allowed for a search. Default is zero, no time limit RFC 4511 4.5.1.5)
  # * :deref (one of: Net::LDAP::DerefAliases_Never, Net::LDAP::DerefAliases_Search,
  #   Net::LDAP::DerefAliases_Find, Net::LDAP::DerefAliases_Always. Default is Never.)
  #
  # #search queries the LDAP server and passes <i>each entry</i> to the
  # caller-supplied block, as an object of type Net::LDAP::Entry. If the
  # search returns 1000 entries, the block will be called 1000 times. If the
  # search returns no entries, the block will not be called.
  #
  # #search returns either a result-set or a boolean, depending on the value
  # of the <tt>:return_result</tt> argument. The default behavior is to
  # return a result set, which is an Array of objects of class
  # Net::LDAP::Entry. If you request a result set and #search fails with an
  # error, it will return nil. Call #get_operation_result to get the error
  # information returned by
  # the LDAP server.
  #
  # When <tt>:return_result => false, </tt> #search will return only a
  # Boolean, to indicate whether the operation succeeded. This can improve
  # performance with very large result sets, because the library can discard
  # each entry from memory after your block processes it.
  #
  #  treebase = "dc=example, dc=com"
  #  filter = Net::LDAP::Filter.eq("mail", "a*.com")
  #  attrs = ["mail", "cn", "sn", "objectclass"]
  #  ldap.search(:base => treebase, :filter => filter, :attributes => attrs,
  #              :return_result => false) do |entry|
  #    puts "DN: #{entry.dn}"
  #    entry.each do |attr, values|
  #      puts ".......#{attr}:"
  #      values.each do |value|
  #        puts "          #{value}"
  #      end
  #    end
  #  end
  def search(args = {})
    unless args[:ignore_server_caps]
      args[:paged_searches_supported] = paged_searches_supported?
    end

    args[:base] ||= @base
    return_result_set = args[:return_result] != false
    result_set = return_result_set ? [] : nil

    instrument "search.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.search(args) do |entry|
          result_set << entry if result_set
          yield entry if block_given?
        end
      end

      if return_result_set
        unless @result.nil?
          if ResultCodesSearchSuccess.include?(@result.result_code)
            result_set
          end
        end
      else
        @result.success?
      end
    end
  end

  # #bind connects to an LDAP server and requests authentication based on
  # the <tt>:auth</tt> parameter passed to #open or #new. It takes no
  # parameters.
  #
  # User code does not need to call #bind directly. It will be called
  # implicitly by the library whenever you invoke an LDAP operation, such as
  # #search or #add.
  #
  # It is useful, however, to call #bind in your own code when the only
  # operation you intend to perform against the directory is to validate a
  # login credential. #bind returns true or false to indicate whether the
  # binding was successful. Reasons for failure include malformed or
  # unrecognized usernames and incorrect passwords. Use
  # #get_operation_result to find out what happened in case of failure.
  #
  # Here's a typical example using #bind to authenticate a credential which
  # was (perhaps) solicited from the user of a web site:
  #
  #  require 'net/ldap'
  #  ldap = Net::LDAP.new
  #  ldap.host = your_server_ip_address
  #  ldap.port = 389
  #  ldap.auth your_user_name, your_user_password
  #  if ldap.bind
  #    # authentication succeeded
  #  else
  #    # authentication failed
  #    p ldap.get_operation_result
  #  end
  #
  # Here's a more succinct example which does exactly the same thing, but
  # collects all the required parameters into arguments:
  #
  #  require 'net/ldap'
  #  ldap = Net::LDAP.new(:host => your_server_ip_address, :port => 389)
  #  if ldap.bind(:method => :simple, :username => your_user_name,
  #               :password => your_user_password)
  #    # authentication succeeded
  #  else
  #    # authentication failed
  #    p ldap.get_operation_result
  #  end
  #
  # You don't need to pass a user-password as a String object to bind. You
  # can also pass a Ruby Proc object which returns a string. This will cause
  # bind to execute the Proc (which might then solicit input from a user
  # with console display suppressed). The String value returned from the
  # Proc is used as the password.
  #
  # You don't have to create a new instance of Net::LDAP every time you
  # perform a binding in this way. If you prefer, you can cache the
  # Net::LDAP object and re-use it to perform subsequent bindings,
  # <i>provided</i> you call #auth to specify a new credential before
  # calling #bind. Otherwise, you'll just re-authenticate the previous user!
  # (You don't need to re-set the values of #host and #port.) As noted in
  # the documentation for #auth, the password parameter can be a Ruby Proc
  # instead of a String.
  def bind(auth = @auth)
    instrument "bind.net_ldap" do |payload|
      if @open_connection
        payload[:connection] = @open_connection
        payload[:bind]       = @result = @open_connection.bind(auth)
      else
        begin
          conn = new_connection
          payload[:connection] = conn
          payload[:bind]       = @result = conn.bind(auth)
        ensure
          conn.close if conn
        end
      end

      @result.success?
    end
  end

  # #bind_as is for testing authentication credentials.
  #
  # As described under #bind, most LDAP servers require that you supply a
  # complete DN as a binding-credential, along with an authenticator such as
  # a password. But for many applications (such as authenticating users to a
  # Rails application), you often don't have a full DN to identify the user.
  # You usually get a simple identifier like a username or an email address,
  # along with a password. #bind_as allows you to authenticate these
  # user-identifiers.
  #
  # #bind_as is a combination of a search and an LDAP binding. First, it
  # connects and binds to the directory as normal. Then it searches the
  # directory for an entry corresponding to the email address, username, or
  # other string that you supply. If the entry exists, then #bind_as will
  # <b>re-bind</b> as that user with the password (or other authenticator)
  # that you supply.
  #
  # #bind_as takes the same parameters as #search, <i>with the addition of
  # an authenticator.</i> Currently, this authenticator must be
  # <tt>:password</tt>. Its value may be either a String, or a +proc+ that
  # returns a String. #bind_as returns +false+ on failure. On success, it
  # returns a result set, just as #search does. This result set is an Array
  # of objects of type Net::LDAP::Entry. It contains the directory
  # attributes corresponding to the user. (Just test whether the return
  # value is logically true, if you don't need this additional information.)
  #
  # Here's how you would use #bind_as to authenticate an email address and
  # password:
  #
  #  require 'net/ldap'
  #
  #  user, psw = "joe_user@yourcompany.com", "joes_psw"
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = "192.168.0.100"
  #  ldap.port = 389
  #  ldap.auth "cn=manager, dc=yourcompany, dc=com", "topsecret"
  #
  #  result = ldap.bind_as(:base => "dc=yourcompany, dc=com",
  #                        :filter => "(mail=#{user})",
  #                        :password => psw)
  #  if result
  #    puts "Authenticated #{result.first.dn}"
  #  else
  #    puts "Authentication FAILED."
  #  end
  def bind_as(args = {})
    result = false
    open do |me|
      rs = search args
      if rs and rs.first and dn = rs.first.dn
        password = args[:password]
        password = password.call if password.respond_to?(:call)
        result = rs if bind(:method => :simple, :username => dn,
                            :password => password)
      end
    end
    result
  end

  # Adds a new entry to the remote LDAP server.
  # Supported arguments:
  # :dn :: Full DN of the new entry
  # :attributes :: Attributes of the new entry.
  #
  # The attributes argument is supplied as a Hash keyed by Strings or
  # Symbols giving the attribute name, and mapping to Strings or Arrays of
  # Strings giving the actual attribute values. Observe that most LDAP
  # directories enforce schema constraints on the attributes contained in
  # entries. #add will fail with a server-generated error if your attributes
  # violate the server-specific constraints.
  #
  # Here's an example:
  #
  #  dn = "cn=George Smith, ou=people, dc=example, dc=com"
  #  attr = {
  #    :cn => "George Smith",
  #    :objectclass => ["top", "inetorgperson"],
  #    :sn => "Smith",
  #    :mail => "gsmith@example.com"
  #  }
  #  Net::LDAP.open(:host => host) do |ldap|
  #    ldap.add(:dn => dn, :attributes => attr)
  #  end
  def add(args)
    instrument "add.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.add(args)
      end
      @result.success?
    end
  end

  # Modifies the attribute values of a particular entry on the LDAP
  # directory. Takes a hash with arguments. Supported arguments are:
  # :dn :: (the full DN of the entry whose attributes are to be modified)
  # :operations :: (the modifications to be performed, detailed next)
  #
  # This method returns True or False to indicate whether the operation
  # succeeded or failed, with extended information available by calling
  # #get_operation_result.
  #
  # Also see #add_attribute, #replace_attribute, or #delete_attribute, which
  # provide simpler interfaces to this functionality.
  #
  # The LDAP protocol provides a full and well thought-out set of operations
  # for changing the values of attributes, but they are necessarily somewhat
  # complex and not always intuitive. If these instructions are confusing or
  # incomplete, please send us email or create an issue on GitHub.
  #
  # The :operations parameter to #modify takes an array of
  # operation-descriptors. Each individual operation is specified in one
  # element of the array, and most LDAP servers will attempt to perform the
  # operations in order.
  #
  # Each of the operations appearing in the Array must itself be an Array
  # with exactly three elements:
  # an operator :: must be :add, :replace, or :delete
  # an attribute name :: the attribute name (string or symbol) to modify
  # a value :: either a string or an array of strings.
  #
  # The :add operator will, unsurprisingly, add the specified values to the
  # specified attribute. If the attribute does not already exist, :add will
  # create it. Most LDAP servers will generate an error if you try to add a
  # value that already exists.
  #
  # :replace will erase the current value(s) for the specified attribute, if
  # there are any, and replace them with the specified value(s).
  #
  # :delete will remove the specified value(s) from the specified attribute.
  # If you pass nil, an empty string, or an empty array as the value
  # parameter to a :delete operation, the _entire_ _attribute_ will be
  # deleted, along with all of its values.
  #
  # For example:
  #
  #  dn = "mail=modifyme@example.com, ou=people, dc=example, dc=com"
  #  ops = [
  #    [:add, :mail, "aliasaddress@example.com"],
  #    [:replace, :mail, ["newaddress@example.com", "newalias@example.com"]],
  #    [:delete, :sn, nil]
  #  ]
  #  ldap.modify :dn => dn, :operations => ops
  #
  # <i>(This example is contrived since you probably wouldn't add a mail
  # value right before replacing the whole attribute, but it shows that
  # order of execution matters. Also, many LDAP servers won't let you delete
  # SN because that would be a schema violation.)</i>
  #
  # It's essential to keep in mind that if you specify more than one
  # operation in a call to #modify, most LDAP servers will attempt to
  # perform all of the operations in the order you gave them. This matters
  # because you may specify operations on the same attribute which must be
  # performed in a certain order.
  #
  # Most LDAP servers will _stop_ processing your modifications if one of
  # them causes an error on the server (such as a schema-constraint
  # violation). If this happens, you will probably get a result code from
  # the server that reflects only the operation that failed, and you may or
  # may not get extended information that will tell you which one failed.
  # #modify has no notion of an atomic transaction. If you specify a chain
  # of modifications in one call to #modify, and one of them fails, the
  # preceding ones will usually not be "rolled back", resulting in a
  # partial update. This is a limitation of the LDAP protocol, not of
  # Net::LDAP.
  #
  # The lack of transactional atomicity in LDAP means that you're usually
  # better off using the convenience methods #add_attribute,
  # #replace_attribute, and #delete_attribute, which are wrappers over
  # #modify. However, certain LDAP servers may provide concurrency
  # semantics, in which the several operations contained in a single #modify
  # call are not interleaved with other modification-requests received
  # simultaneously by the server. It bears repeating that this concurrency
  # does _not_ imply transactional atomicity, which LDAP does not provide.
  def modify(args)
    instrument "modify.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.modify(args)
      end
      @result.success?
    end
  end

  # Password Modify
  #
  # Change existing password:
  #
  #  dn = 'uid=modify-password-user1,ou=People,dc=rubyldap,dc=com'
  #  auth = {
  #    method: :simple,
  #    username: dn,
  #    password: 'passworD1'
  #  }
  #  ldap.password_modify(dn: dn,
  #                       auth: auth,
  #                       old_password: 'passworD1',
  #                       new_password: 'passworD2')
  #
  # Or get the LDAP server to generate a password for you:
  #
  #  dn = 'uid=modify-password-user1,ou=People,dc=rubyldap,dc=com'
  #  auth = {
  #    method: :simple,
  #    username: dn,
  #    password: 'passworD1'
  #  }
  #  ldap.password_modify(dn: dn,
  #                       auth: auth,
  #                       old_password: 'passworD1')
  #
  #  ldap.get_operation_result.extended_response[0][0] #=> 'VtcgGf/G'
  #
  def password_modify(args)
    instrument "modify_password.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.password_modify(args)
      end
      @result.success?
    end
  end

  # Add a value to an attribute. Takes the full DN of the entry to modify,
  # the name (Symbol or String) of the attribute, and the value (String or
  # Array). If the attribute does not exist (and there are no schema
  # violations), #add_attribute will create it with the caller-specified
  # values. If the attribute already exists (and there are no schema
  # violations), the caller-specified values will be _added_ to the values
  # already present.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #replace_attribute and
  # #delete_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.add_attribute dn, :mail, "newmailaddress@example.com"
  def add_attribute(dn, attribute, value)
    modify(:dn => dn, :operations => [[:add, attribute, value]])
  end

  # Replace the value of an attribute. #replace_attribute can be thought of
  # as equivalent to calling #delete_attribute followed by #add_attribute.
  # It takes the full DN of the entry to modify, the name (Symbol or String)
  # of the attribute, and the value (String or Array). If the attribute does
  # not exist, it will be created with the caller-specified value(s). If the
  # attribute does exist, its values will be _discarded_ and replaced with
  # the caller-specified values.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #add_attribute and #delete_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.replace_attribute dn, :mail, "newmailaddress@example.com"
  def replace_attribute(dn, attribute, value)
    modify(:dn => dn, :operations => [[:replace, attribute, value]])
  end

  # Delete an attribute and all its values. Takes the full DN of the entry
  # to modify, and the name (Symbol or String) of the attribute to delete.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #add_attribute and #replace_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.delete_attribute dn, :mail
  def delete_attribute(dn, attribute)
    modify(:dn => dn, :operations => [[:delete, attribute, nil]])
  end

  # Rename an entry on the remote DIS by changing the last RDN of its DN.
  #
  # _Documentation_ _stub_
  def rename(args)
    instrument "rename.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.rename(args)
      end
      @result.success?
    end
  end
  alias_method :modify_rdn, :rename

  # Delete an entry from the LDAP directory. Takes a hash of arguments. The
  # only supported argument is :dn, which must give the complete DN of the
  # entry to be deleted.
  #
  # Returns True or False to indicate whether the delete succeeded. Extended
  # status information is available by calling #get_operation_result.
  #
  #  dn = "mail=deleteme@example.com, ou=people, dc=example, dc=com"
  #  ldap.delete :dn => dn
  def delete(args)
    instrument "delete.net_ldap", args do |payload|
      @result = use_connection(args) do |conn|
        conn.delete(args)
      end
      @result.success?
    end
  end

  # Delete an entry from the LDAP directory along with all subordinate entries.
  # the regular delete method will fail to delete an entry if it has subordinate
  # entries. This method sends an extra control code to tell the LDAP server
  # to do a tree delete. ('1.2.840.113556.1.4.805')
  #
  # Returns True or False to indicate whether the delete succeeded. Extended
  # status information is available by calling #get_operation_result.
  #
  #  dn = "mail=deleteme@example.com, ou=people, dc=example, dc=com"
  #  ldap.delete_tree :dn => dn
  def delete_tree(args)
    delete(args.merge(:control_codes => [[Net::LDAP::LDAPControls::DELETE_TREE, true]]))
  end
  # This method is experimental and subject to change. Return the rootDSE
  # record from the LDAP server as a Net::LDAP::Entry, or an empty Entry if
  # the server doesn't return the record.
  #--
  # cf. RFC4512 graf 5.1.
  # Note that the rootDSE record we return on success has an empty DN, which
  # is correct. On failure, the empty Entry will have a nil DN. There's no
  # real reason for that, so it can be changed if desired. The funky
  # number-disagreements in the set of attribute names is correct per the
  # RFC. We may be called by #search itself, which may need to determine
  # things like paged search capabilities. So to avoid an infinite regress,
  # set :ignore_server_caps, which prevents us getting called recursively.
  #++
  def search_root_dse
    rs = search(:ignore_server_caps => true, :base => "",
                :scope => SearchScope_BaseObject,
                :attributes => [
                  :altServer,
                  :namingContexts,
                  :supportedCapabilities,
                  :supportedControl,
                  :supportedExtension,
                  :supportedFeatures,
                  :supportedLdapVersion,
                  :supportedSASLMechanisms,
                ])
    (rs and rs.first) or Net::LDAP::Entry.new
  end

  # Return the root Subschema record from the LDAP server as a
  # Net::LDAP::Entry, or an empty Entry if the server doesn't return the
  # record. On success, the Net::LDAP::Entry returned from this call will
  # have the attributes :dn, :objectclasses, and :attributetypes. If there
  # is an error, call #get_operation_result for more information.
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = "your.ldap.host"
  #  ldap.auth "your-user-dn", "your-psw"
  #  subschema_entry = ldap.search_subschema_entry
  #
  #  subschema_entry.attributetypes.each do |attrtype|
  #    # your code
  #  end
  #
  #  subschema_entry.objectclasses.each do |attrtype|
  #    # your code
  #  end
  #--
  # cf. RFC4512 section 4, particulary graff 4.4.
  # The :dn attribute in the returned Entry is the subschema name as
  # returned from the server. Set :ignore_server_caps, see the notes in
  # search_root_dse.
  #++
  def search_subschema_entry
    rs = search(:ignore_server_caps => true, :base => "",
                :scope => SearchScope_BaseObject,
                :attributes => [:subschemaSubentry])
    return Net::LDAP::Entry.new unless (rs and rs.first)

    subschema_name = rs.first.subschemasubentry
    return Net::LDAP::Entry.new unless (subschema_name and subschema_name.first)

    rs = search(:ignore_server_caps => true, :base => subschema_name.first,
                :scope => SearchScope_BaseObject,
                :filter => "objectclass=subschema",
                :attributes => [:objectclasses, :attributetypes])
    (rs and rs.first) or Net::LDAP::Entry.new
  end

  #--
  # Convenience method to query server capabilities.
  # Only do this once per Net::LDAP object.
  # Note, we call a search, and we might be called from inside a search!
  # MUST refactor the root_dse call out.
  #++
  def paged_searches_supported?
    # active directory returns that it supports paged results. However
    # it returns binary data in the rfc2696_cookie which throws an
    # encoding exception breaking searching.
    return false if @force_no_page
    @server_caps ||= search_root_dse
    @server_caps[:supportedcontrol].include?(Net::LDAP::LDAPControls::PAGED_RESULTS)
  end

  # Mask auth password
  def inspect
    inspected = super
    inspected.gsub! @auth[:password], "*******" if @auth[:password]
    inspected
  end

  # Internal: Set @open_connection for testing
  def connection=(connection)
    @open_connection = connection
  end

  private

  # Yields an open connection if there is one, otherwise establishes a new
  # connection, binds, and yields it. If binding fails, it will return the
  # result from that, and :use_connection: will not yield at all. If not
  # the return value is whatever is returned from the block.
  def use_connection(args)
    if @open_connection
      yield @open_connection
    else
      begin
        conn = new_connection
        result = conn.bind(args[:auth] || @auth)
        return result unless result.result_code == Net::LDAP::ResultCodeSuccess
        yield conn
      ensure
        conn.close if conn
      end
    end
  end

  # Establish a new connection to the LDAP server
  def new_connection
    connection = Net::LDAP::Connection.new \
      :host                    => @host,
      :port                    => @port,
      :hosts                   => @hosts,
      :encryption              => @encryption,
      :instrumentation_service => @instrumentation_service,
      :connect_timeout         => @connect_timeout

    # Force connect to see if there's a connection error
    connection.socket
    connection
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Net::LDAP::ConnectionRefusedError => e
    @result = {
      :resultCode   => 52,
      :errorMessage => ResultStrings[ResultCodeUnavailable],
    }
    raise e
  end

  # Normalize encryption parameter the constructor accepts, expands a few
  # convenience symbols into recognizable hashes
  def normalize_encryption(args)
    return if args.nil?
    return args if args.is_a? Hash

    case method = args.to_sym
    when :simple_tls, :start_tls
      { :method => method, :tls_options => {} }
    end
  end

end # class LDAP
