# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::DatabaseSchemaRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check runner available to devops users'

  describe '#run' do
    subject(:result) { runner.run }

    context 'when database needs migration' do
      before do
        context = instance_double(ActiveRecord::MigrationContext, needs_migration?: true)
        allow(ActiveRecord::Base.connection_pool).to receive(:migration_context).and_return(context)
      end

      it { is_expected.to be_pending }
    end

    context 'when database does not need migration' do
      before do
        context = instance_double(ActiveRecord::MigrationContext, needs_migration?: false)
        allow(ActiveRecord::Base.connection_pool).to receive(:migration_context).and_return(context)
      end

      it { is_expected.to be_ok }
    end
  end
end
