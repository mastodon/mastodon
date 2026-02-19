# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::SidekiqProcessCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check available to devops users'

  describe 'pass?' do
    context 'when missing queues is empty' do
      before do
        process_set = instance_double(Sidekiq::ProcessSet, reduce: [])
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
      end

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end

    context 'when missing queues is not empty' do
      before do
        process_set = instance_double(Sidekiq::ProcessSet, reduce: [:something])
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end
  end

  describe 'message' do
    it 'sends values to message instance' do
      allow(Admin::SystemCheck::Message).to receive(:new).with(:sidekiq_process_check, 'default, push, mailers, pull, scheduler, ingress, fasp')

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(:sidekiq_process_check, 'default, push, mailers, pull, scheduler, ingress, fasp')
    end
  end
end
