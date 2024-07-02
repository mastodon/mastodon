# frozen_string_literal: true

require 'rails_helper'

describe Admin::Db::SchemaParser do
  let(:dummy_schema) do
    <<~SCHEMA
      # Comment
      ActiveRecord::Schema[7.1].define(version: 23) do
        create_table "people", force: :cascade do |t|
          t.string "name"
        end

        create_table "posts", force: :cascade do |t|
          t.string "title", null: false
          t.bigint "size", null: false
          t.string "description"
          # t.index ["size", "title"], name: "index_posts_on_size_and_title"
          t.index ["title"], name: "index_posts_on_title", unique: true
          t.index ["size"], name: "index_posts_on_size"
        end

        # add_index "people", ["name"], name: "commented_out_index"
        add_index "people", ["name"], name: "index_people_on_name"
      end
    SCHEMA
  end
  let(:schema_parser) { described_class.new(dummy_schema) }

  describe '#indexes_by_table' do
    subject { schema_parser.indexes_by_table }

    it 'returns index info for all affected tables' do
      expect(subject.keys).to match_array(%w(people posts))
    end

    it 'returns all index information for the `people` table' do
      people_info = subject['people']
      expect(people_info.map(&:name)).to contain_exactly('index_people_on_name')
    end

    it 'returns all index information for the `posts` table' do
      posts_info = subject['posts']
      expect(posts_info.map(&:name)).to contain_exactly(
        'index_posts_on_title', 'index_posts_on_size'
      )
    end
  end
end
