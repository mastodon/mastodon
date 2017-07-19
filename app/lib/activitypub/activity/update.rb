# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Account'
      update_account
    end
  end

  private

  def update_account
    raise NotImplementedError
  end
end
