# frozen_string_literal: true

require 'rails_helper'

describe Admin::SystemCheck::SidekiqProcessCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  describe 'skip?' do
    context 'when user can view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(true) }

      it 'returns false' do
        expect(check.skip?).to be false
      end
    end

    context 'when user cannot view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(false) }

      it 'returns true' do
        expect(check.skip?).to be true
      end
    end
  end

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
      allow(Admin::SystemCheck::Message).to receive(:new).with(:sidekiq_process_check, 'default, push, mailers, pull, scheduler, ingress')

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(:sidekiq_process_check, 'default, push, mailers, pull, scheduler, ingress')
    end
  end
end
