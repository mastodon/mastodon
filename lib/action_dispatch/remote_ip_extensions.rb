# frozen_string_literal: true

# Mastodon is not made to be directly accessed without a reverse proxy.
# This monkey-patch prevents remote IP address spoofing when being accessed
# directly.
#
# See PR: https://github.com/rails/rails/pull/51610

# In addition to the PR above, it also raises an error if a request with
# `X-Forwarded-For` or `Client-Ip` comes directly from a client without
# going through a trusted proxy.

# rubocop:disable all -- This is a mostly vendored file

module ActionDispatch
  class RemoteIp
    module GetIpExtensions
      def calculate_ip
        # Set by the Rack web server, this is a single value.
        remote_addr = sanitize_ips(ips_from(@req.remote_addr)).last

        # Could be a CSV list and/or repeated headers that were concatenated.
        client_ips    = sanitize_ips(ips_from(@req.client_ip)).reverse!
        forwarded_ips = sanitize_ips(@req.forwarded_for || []).reverse!

        # `Client-Ip`, `Forwarded`, and `X-Forwarded-For` should not, generally, all
        # be set. If several of them are set, it means that either:
        #
        # 1) This request passed through proxies with incompatible IP header
        #
        # 2) The client passed the headers the proxy servers weren't using
        #     themselves.
        #
        # Either way, there is no way for us to determine which header is the right one
        # after the fact. Since we have no idea, if we are concerned about IP spoofing
        # we need to give up and explode. (If you're not concerned about IP spoofing you
        # can turn the `ip_spoofing_check` option off.)
        check_ip(client_ips, forwarded_ips) if @check_ip

        # NOTE: Mastodon addition to make sure we don't get requests from a non-trusted client
        if @check_ip && (forwarded_ips.last || client_ips.last) && !@proxies.any? { |proxy| proxy === remote_addr }
          raise IpSpoofAttackError, "IP spoofing attack?! client #{remote_addr} is not a trusted proxy " \
            "HTTP_CLIENT_IP=#{@req.client_ip.inspect} " \
            "HTTP_X_FORWARDED_FOR=#{@req.x_forwarded_for.inspect}"
        end

        # We assume these things about the IP headers:
        #
        #     - X-Forwarded-For will be a list of IPs, one per proxy, or blank
        #     - Client-Ip is propagated from the outermost proxy, or is blank
        #     - REMOTE_ADDR will be the IP that made the request to Rack
        ips = forwarded_ips + client_ips
        ips.compact!

        # If every single IP option is in the trusted list, return the IP that's
        # furthest away
        filter_proxies([remote_addr] + ips).first || ips.last || remote_addr
      end
    end
  end
end

ActionDispatch::RemoteIp::GetIp.prepend(ActionDispatch::RemoteIp::GetIpExtensions)

# rubocop:enable all
