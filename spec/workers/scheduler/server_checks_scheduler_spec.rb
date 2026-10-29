# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::ServerChecksScheduler do
  let(:worker) { described_class.new }
  let(:runner_class) do
    Class.new do
      include Admin::ServerCheck::Runner

      attr_reader :status, :data, :severity

      def initialize(status: :ok, data: {}, severity: :critical, async: true)
        @status = status
        @data = data
        @severity = severity
        @async = async
      end

      def async?
        @async
      end

      def run
        raise 'spec error' if status == :error

        result(status:, data:, severity:)
      end
    end
  end

  describe '#perform' do
    let(:runner) { runner_class.new }
    let(:check) { Fabricate('Admin::ServerCheck', key: 'rules') }
    let(:checks) { [check] }

    before do
      allow(Admin::ServerCheck).to receive(:checks).and_return(checks)
      allow(Admin::ServerCheck::RulesRunner).to receive(:new).and_return(runner)
    end

    it 'runs the check' do
      expect { worker.perform }.to(change { check.reload.status }.to('ok'))
    end

    context 'when the check is not async' do
      let(:runner) { runner_class.new(async: false) }

      it 'does not run the check' do
        expect { worker.perform }.to_not(change { check.reload.status })
      end
    end

    context 'when the check is running' do
      let(:check) { Fabricate('Admin::ServerCheck', key: 'rules', status: :running) }

      it 'does not run the check' do
        expect { worker.perform }.to_not(change { check.reload.status })
      end

      context 'when it is stuck' do
        let(:check) { Fabricate('Admin::ServerCheck', key: 'rules', status: :running, updated_at: 2.hours.ago) }

        it 'runs the check' do
          expect { worker.perform }.to(change { check.reload.status }.from('running').to('ok'))
        end
      end
    end

    context 'when there is an error' do
      let(:runner) { runner_class.new(status: :error) }

      it 'runs the check and stores the error' do
        expect { worker.perform }.to(change { check.reload.status }.to('error'))
      end
    end
  end
end
