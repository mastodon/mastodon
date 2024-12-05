# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::DatabaseSchemaCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check available to devops users'

  describe 'pass?' do
    context 'when database needs migration' do
      before do
        context = instance_double(ActiveRecord::MigrationContext, needs_migration?: true)
        allow(ActiveRecord::Base.connection).to receive(:migration_context).and_return(context)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when database does not need migration' do
      before do
        context = instance_double(ActiveRecord::MigrationContext, needs_migration?: false)
        allow(ActiveRecord::Base.connection).to receive(:migration_context).and_return(context)
      end

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe 'message' do
    it 'sends class name symbol to message instance' do
      allow(Admin::SystemCheck::Message).to receive(:new).with(:database_schema_check)

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(:database_schema_check)
    end
  end
end
