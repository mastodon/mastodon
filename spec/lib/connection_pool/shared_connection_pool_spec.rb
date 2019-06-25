# frozen_string_literal: true

require 'rails_helper'

describe ConnectionPool::SharedConnectionPool do
  let(:shared_size) { Concurrent::AtomicFixnum.new }

  subject { described_class.new(shared_size, size: 5, timeout: 5) { Object.new } }

  pending
end
