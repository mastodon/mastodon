# frozen_string_literal: true

require 'test_helper'

class TrackableHooksTest < Devise::IntegrationTest
  test "trackable should not run model validations" do
    sign_in_as_user

    refute User.validations_performed
  end

  test "current and last sign in timestamps are updated on each sign in" do
    user = create_user
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at

    sign_in_as_user
    user.reload

    assert user.current_sign_in_at.acts_like?(:time)
    assert user.last_sign_in_at.acts_like?(:time)

    assert_equal user.current_sign_in_at, user.last_sign_in_at
    assert user.current_sign_in_at >= user.created_at

    delete destroy_user_session_path
    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)

    sign_in_as_user
    user.reload
    assert user.current_sign_in_at > user.last_sign_in_at
  end

  test "current and last sign in remote ip are updated on each sign in" do
    user = create_user
    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip

    sign_in_as_user
    user.reload

    assert_equal "127.0.0.1", user.current_sign_in_ip
    assert_equal "127.0.0.1", user.last_sign_in_ip
  end

  test "current remote ip returns original ip behind a non transparent proxy" do
    user = create_user

    arbitrary_ip = '200.121.1.69'
    sign_in_as_user do
      header 'HTTP_X_FORWARDED_FOR', arbitrary_ip
    end
    user.reload
    assert_equal arbitrary_ip, user.current_sign_in_ip
  end

  test "increase sign in count" do
    user = create_user
    assert_equal 0, user.sign_in_count

    sign_in_as_user
    user.reload
    assert_equal 1, user.sign_in_count

    delete destroy_user_session_path
    sign_in_as_user
    user.reload
    assert_equal 2, user.sign_in_count
  end

  test "does not update anything if user has signed out along the way" do
    swap Devise, allow_unconfirmed_access_for: 0.days do
      user = create_user(confirm: false)
      sign_in_as_user

      user.reload
      assert_nil user.current_sign_in_at
      assert_nil user.last_sign_in_at
    end
  end

  test "do not track if devise.skip_trackable is set" do
    user = create_user
    sign_in_as_user do
      header 'devise.skip_trackable', '1'
    end
    user.reload
    assert_equal 0, user.sign_in_count
    delete destroy_user_session_path

    sign_in_as_user do
      header 'devise.skip_trackable', false
    end
    user.reload
    assert_equal 1, user.sign_in_count
  end

end
