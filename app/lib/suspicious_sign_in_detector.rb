# frozen_string_literal: true

class SuspiciousSignInDetector
  IPV6_TOLERANCE_MASK = 64
  IPV4_TOLERANCE_MASK = 16

  def initialize(user)
    @user = user
  end

  def suspicious?(request)
    !sufficient_security_measures? && !freshly_signed_up? && !previously_seen_ip?(request)
  end

  private

  def sufficient_security_measures?
    @user.otp_required_for_login?
  end

  def previously_seen_ip?(request)
    @user.ips.contained_by(masked_ip(request)).exists?
  end

  def freshly_signed_up?
    @user.current_sign_in_at.blank?
  end

  def masked_ip(request)
    masked_ip_addr = begin
      ip_addr = IPAddr.new(request.remote_ip)

      if ip_addr.ipv6?
        ip_addr.mask(IPV6_TOLERANCE_MASK)
      else
        ip_addr.mask(IPV4_TOLERANCE_MASK)
      end
    end

    "#{masked_ip_addr}/#{masked_ip_addr.prefix}"
  end
end
