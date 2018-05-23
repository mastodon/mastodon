require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(DataMapper)
  puts "** require 'dm-core' to run the specs in #{__FILE__}"
else

  DataMapper.setup(:default, 'sqlite::memory:')

  module DmOrmSpec
    class User
      include DataMapper::Resource
      property :id,   Serial
      property :name, String
      property :rating, Integer
      has n, :notes, :child_key => [:owner_id]
    end

    class Note
      include DataMapper::Resource
      property :id,   Serial
      property :body, String
      belongs_to :owner, 'User'
    end

    require  'dm-migrations'
    DataMapper.finalize
    DataMapper.auto_migrate!

    # here be the specs!
    describe DataMapper::Resource::OrmAdapter do
      before do
        User.destroy
        Note.destroy
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }

        def reload_model(model)
          model.class.get(model.id)
        end
      end
    end
  end
end
