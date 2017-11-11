require 'rails_helper'

RSpec.describe RequestApprovalService do
  let!(:admin) { Fabricate(:user, admin: true) }
  let(:user) { Fabricate(:user) }
  subject { RequestApprovalService.new }

  around do |example|
    queue_adapter = ActiveJob::Base.queue_adapter
    require_approval = Setting.require_approval?
    example.run
    ActiveJob::Base.queue_adapter = queue_adapter
    Setting.require_approval = require_approval
  end

  context 'require_approval is true' do
    before do
      Setting.require_approval = true
    end

    it 'delivers approval request later' do
      ActiveJob::Base.queue_adapter = :test
      expect{ subject.call(user) }.to have_enqueued_job(ActionMailer::DeliveryJob)
    end

    it 'pends approval' do
      subject.call(user)
      expect(user.approved?).to be false
    end
  end

  context 'require_approval is false' do
    before do
      Setting.require_approval = false
    end

    it 'does not request approval' do
      ActiveJob::Base.queue_adapter = :test
      expect{ subject.call(user) }.not_to have_enqueued_job(ActionMailer::DeliveryJob)
    end

    it 'automatically approve new user' do
      subject.call(user)
      expect(user.approved?).to be true
    end
  end
end
