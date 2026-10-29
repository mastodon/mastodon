# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck do
  let(:runner) do
    Class.new do
      include Admin::ServerCheck::Runner

      attr_reader :status, :data, :severity

      def initialize(status:, data:, severity: :critical, async: true)
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

  describe '.checks' do
    let(:checks) { described_class.checks }

    it 'returns all defined checks' do
      expect(checks.size).to eq(6)

      expect(checks.map(&:key))
        .to match_array(%w(software_version media_privacy database_schema elastic_search rules sidekiq_process))
    end

    context 'when there are no records' do
      before do
        described_class.destroy_all
      end

      it 'returns new instances' do
        expect(checks.all?(&:new_record?)).to be(true)
      end
    end

    context 'when there are records' do
      before do
        Fabricate('Admin::ServerCheck', key: 'rules')
      end

      it 'returns a mix of new and saved' do
        expect(checks.size).to eq(6)

        rule = checks.find { |c| c.key == 'rules' }
        expect(rule.new_record?).to be(false)
        expect(checks.reject { |c| c.key == 'rules' }.all?(&:new_record?)).to be(true)
      end
    end
  end

  describe '#run' do
    subject(:check) { described_class.new(key: 'rules') }

    let(:status) { :ok }
    let(:data) { {} }
    let(:severity) { :critical }

    before do
      allow(Admin::ServerCheck::RulesRunner).to receive(:new).and_return(runner.new(status:, data:, severity:))
    end

    context 'when the runner passes' do
      it 'saves runner result' do
        check.run

        expect(check.status).to eq(status.to_s)
        expect(check.data).to eq(data)
        expect(check.severity).to eq(severity.to_s)
        expect(check.checked_at).to be_present
      end
    end

    context 'when the runner is pending' do
      let(:status) { :pending }
      let(:data) { { 'reason' => 'spec' } }
      let(:severity) { :warning }

      it 'saves runner result' do
        check.run

        expect(check.status).to eq(status.to_s)
        expect(check.data).to eq(data)
        expect(check.severity).to eq(severity.to_s)
        expect(check.checked_at).to be_present
      end
    end

    context 'when there is an error' do
      let(:status) { :error }
      let(:severity) { :critical }

      it 'saves runner result' do
        check.run

        expect(check.status).to eq('error')
        expect(check.data).to eq({ 'error' => 'spec error' })
        expect(check.severity).to eq(severity.to_s)
        expect(check.checked_at).to be_present
      end
    end
  end

  describe '#run!' do
    subject(:check) { described_class.new(key: 'rules') }

    let(:status) { :error }
    let(:data) { {} }
    let(:severity) { :critical }

    before do
      allow(Admin::ServerCheck::RulesRunner).to receive(:new).and_return(runner.new(status:, data:, severity:))
    end

    context 'when there is an error' do
      it 'saves runner result' do
        expect { check.run! }.to raise_error(StandardError)

        expect(check.status).to eq('error')
        expect(check.data).to eq({ 'error' => 'spec error' })
        expect(check.severity).to eq(severity.to_s)
        expect(check.checked_at).to be_present
      end
    end
  end

  describe '#prepare' do
    subject(:check) { described_class.new(key: 'rules') }

    let(:status) { :ok }
    let(:data) { {} }
    let(:severity) { :critical }

    context 'when the runner is async' do
      before do
        allow(Admin::ServerCheck::RulesRunner).to receive(:new).and_return(runner.new(status:, data:, severity:))
      end

      it 'does not run it' do
        check.prepare

        expect(check.status).to eq('unprocessed')
      end
    end

    context 'when the runner is sync' do
      before do
        allow(Admin::ServerCheck::RulesRunner).to receive(:new).and_return(runner.new(status:, data:, severity:, async: false))
      end

      it 'runs it' do
        check.prepare

        expect(check.status).to eq('ok')
      end
    end
  end
end
