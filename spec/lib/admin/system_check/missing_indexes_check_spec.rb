# frozen_string_literal: true

require 'rails_helper'

describe Admin::SystemCheck::MissingIndexesCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }
  let(:schema_parser) do
    instance_double(Admin::Db::SchemaParser, indexes_by_table: index_info)
  end
  let(:index_info) do
    {
      'users' => [instance_double(Admin::Db::SchemaParser::Index, name: 'index_users_on_profile_id')],
      'posts' => [instance_double(Admin::Db::SchemaParser::Index, name: 'index_posts_on_user_id')],
    }
  end
  let(:posts_indexes) { [] }
  let(:users_indexes) { [] }

  before do
    allow(Admin::Db::SchemaParser).to receive(:new).and_return(schema_parser)
    allow(ActiveRecord::Base.connection).to receive(:indexes).with('posts').and_return(posts_indexes)
    allow(ActiveRecord::Base.connection).to receive(:indexes).with('users').and_return(users_indexes)
  end

  it_behaves_like 'a check available to devops users'

  describe '#pass?' do
    context 'when indexes are missing' do
      let(:posts_indexes) do
        [instance_double(ActiveRecord::ConnectionAdapters::IndexDefinition, name: 'index_posts_on_user_id')]
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when all expected indexes are present' do
      let(:posts_indexes) do
        [instance_double(ActiveRecord::ConnectionAdapters::IndexDefinition, name: 'index_posts_on_user_id')]
      end
      let(:users_indexes) do
        [instance_double(ActiveRecord::ConnectionAdapters::IndexDefinition, name: 'index_users_on_profile_id')]
      end

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe '#message' do
    subject { check.message }

    it 'sets the class name as the message key' do
      expect(subject.key).to eq(:missing_indexes_check)
    end

    it 'sets a list of missing indexes as message value' do
      expect(subject.value).to eq('index_users_on_profile_id, index_posts_on_user_id')
    end
  end
end
