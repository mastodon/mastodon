# frozen_string_literal: true

require 'test_helper'

class TimeoutableTest < ActiveSupport::TestCase

  test 'should be expired' do
    assert new_user.timedout?(31.minutes.ago)
  end

  test 'should not be expired' do
    refute new_user.timedout?(29.minutes.ago)
  end

  test 'should not be expired when params is nil' do
    refute new_user.timedout?(nil)
  end

  test 'should use timeout_in method' do
    user = new_user
    user.instance_eval { def timeout_in; 10.minutes end }

    assert user.timedout?(12.minutes.ago)
    refute user.timedout?(8.minutes.ago)
  end

  test 'should not be expired when timeout_in method returns nil' do
    user = new_user
    user.instance_eval { def timeout_in; nil end }
    refute user.timedout?(10.hours.ago)
  end

  test 'fallback to Devise config option' do
    swap Devise, timeout_in: 1.minute do
      user = new_user
      assert user.timedout?(2.minutes.ago)
      refute user.timedout?(30.seconds.ago)

      Devise.timeout_in = 5.minutes
      refute user.timedout?(2.minutes.ago)
      assert user.timedout?(6.minutes.ago)
    end
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_equal Devise::Models::Timeoutable.required_fields(User), []
  end

  test 'should not raise error if remember_created_at is not empty and rememberable is disabled' do
    user = create_admin(remember_created_at: Time.current)
    assert user.timedout?(31.minutes.ago)
  end
end
