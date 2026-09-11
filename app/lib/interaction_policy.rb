# frozen_string_literal: true

class InteractionPolicy
  POLICY_FLAGS = {
    unsupported_policy: (1 << 0), # Not supported by Mastodon
    public: (1 << 1),             # Everyone is allowed to interact
    followers: (1 << 2),          # Only followers may interact
    following: (1 << 3),          # Only accounts followed by the target may interact
    disabled: (1 << 4),           # All interaction explicitly disabled
  }.freeze

  class SubPolicy
    def initialize(bitmap)
      @bitmap = bitmap
    end

    def as_keys
      POLICY_FLAGS.keys.select { |key| @bitmap.anybits?(POLICY_FLAGS[key]) }.map(&:to_s)
    end

    POLICY_FLAGS.each_key do |key|
      define_method :"#{key}?" do
        @bitmap.anybits?(POLICY_FLAGS[key])
      end
    end

    def missing?
      @bitmap.zero?
    end
  end

  attr_reader :automatic, :manual

  def initialize(bitmap)
    @bitmap = bitmap
    @automatic = SubPolicy.new(@bitmap >> 16)
    @manual = SubPolicy.new(@bitmap & 0xFFFF)
  end
end
