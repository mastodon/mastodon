require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:users, :force => true) {|t| t.string :name; t.integer :rating; }
      create_table(:notes, :force => true) {|t| t.belongs_to :owner, :polymorphic => true }
    end
  end

  module ArOrmSpec
    class User < ActiveRecord::Base
      has_many :notes, :as => :owner
    end

    class AbstractNoteClass < ActiveRecord::Base
      self.abstract_class = true
    end

    class Note < AbstractNoteClass
      belongs_to :owner, :polymorphic => true
    end

    # here be the specs!
    describe '[ActiveRecord orm adapter]' do
      before do
        User.delete_all
        Note.delete_all
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end

      describe "#conditions_to_fields" do
        describe "with non-standard association keys" do
          class PerverseNote < Note
            belongs_to :user, :foreign_key => 'owner_id'
            belongs_to :pwner, :polymorphic => true, :foreign_key => 'owner_id', :foreign_type => 'owner_type'
          end

          let(:user) { User.create! }
          let(:adapter) { PerverseNote.to_adapter }

          it "should convert polymorphic object in conditions to the appropriate fields" do
            adapter.send(:conditions_to_fields, :pwner => user).should == {'owner_id' => user.id, 'owner_type' => user.class.name}
          end

          it "should convert belongs_to object in conditions to the appropriate fields" do
            adapter.send(:conditions_to_fields, :user => user).should == {'owner_id' => user.id}
          end
        end
      end
    end
  end
end
