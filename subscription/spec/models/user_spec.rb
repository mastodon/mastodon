require 'rails_helper'

describe User do
  it 'does not associate a subscription when there is no invite associated with the user' do
    invite = Fabricate(:invite)
    subscription = Fabricate(:stripe_subscription, invite: invite)
    user = Fabricate(:user)

    expect(subscription.reload.user).to be_nil
  end

  it 'does not associate a subscription when the invite is not associated with any subscription' do
    invite = Fabricate(:invite)
    subscription = Fabricate(:stripe_subscription, invite: Fabricate(:invite))
    user = Fabricate(:user, invite: invite)

    expect(subscription.reload.user).to be_nil
  end

  it 'associates a subscription when there is an invite associated with a subscription' do
    invite = Fabricate(:invite)
    subscription = Fabricate(:stripe_subscription, invite: invite)
    user = Fabricate(:user, invite: invite)

    expect(subscription.reload.user).to eq(user)
  end

  it 'does not associate a subscription when there is an invite associated with a subscription \
   but the subscription already has a user' do
    invite = Fabricate(:invite)
    subscription = Fabricate(:stripe_subscription, invite: invite, user_id: Fabricate(:user).id)
    user = Fabricate(:user, invite: invite)

    expect(subscription.reload.user).to_not eq(user)
  end
end