# frozen_string_literal: true

require 'rails_helper'

describe DistributionWorker do
  it 'notifies the authors of the reblogged statuses' do
    user = Fabricate(:user)
    reblog = Fabricate(:status, account: user.account)
    status = Fabricate(:status, reblog: reblog)

    DistributionWorker.new.perform(status.id)

    expect(Notification.where(
      activity: status,
      account: user.account,
      from_account: status.account
    )).to exist
  end

  it 'notifies the mentioned users' do
    user = Fabricate(:user)
    mention = Fabricate(:mention, account: user.account)

    DistributionWorker.new.perform(mention.status.id)

    expect(Notification.where(
      activity: mention,
      account: user.account,
      from_account: mention.status.account
    )).to exist
  end

  it 'does not notify the user mentioned but not included in the audience' do
    user = Fabricate(:user)
    mention = Fabricate(:mention, account: user.account)

    DistributionWorker.new.perform(mention.status.id, [])

    expect(Notification.where(
      activity: mention,
      account: user.account,
      from_account: mention.status.account
    )).not_to exist
  end
end
