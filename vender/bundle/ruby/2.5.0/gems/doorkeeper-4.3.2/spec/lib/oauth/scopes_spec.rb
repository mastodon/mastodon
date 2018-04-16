require 'spec_helper'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string'
require 'doorkeeper/oauth/scopes'

module Doorkeeper::OAuth
  describe Scopes do
    describe '#add' do
      it 'allows you to add scopes with symbols' do
        subject.add :public
        expect(subject.all).to eq(['public'])
      end

      it 'allows you to add scopes with strings' do
        subject.add 'public'
        expect(subject.all).to eq(['public'])
      end

      it 'do not add already included scopes' do
        subject.add :public
        subject.add :public
        expect(subject.all).to eq(['public'])
      end
    end

    describe '#exists' do
      before do
        subject.add :public
      end

      it 'returns true if scope with given name is present' do
        expect(subject.exists?('public')).to be_truthy
      end

      it 'returns false if scope with given name does not exist' do
        expect(subject.exists?('other')).to be_falsey
      end

      it 'handles symbols' do
        expect(subject.exists?(:public)).to be_truthy
        expect(subject.exists?(:other)).to be_falsey
      end
    end

    describe '.from_string' do
      let(:string) { 'public write' }

      subject { Scopes.from_string(string) }

      it { expect(subject).to be_a(Scopes) }

      describe '#all' do
        it 'should be an array of the expected scopes' do
          scopes_array = subject.all
          expect(scopes_array.size).to eq(2)
          expect(scopes_array).to include('public')
          expect(scopes_array).to include('write')
        end
      end
    end

    describe '#+' do
      it 'can add to another scope object' do
        scopes = Scopes.from_string('public') + Scopes.from_string('admin')
        expect(scopes.all).to eq(%w[public admin])
      end

      it 'does not change the existing object' do
        origin = Scopes.from_string('public')
        expect(origin.to_s).to eq('public')
      end

      it 'can add an array to a scope object' do
        scopes = Scopes.from_string('public') + ['admin']
        expect(scopes.all).to eq(%w[public admin])
      end

      it 'raises an error if cannot handle addition' do
        expect do
          Scopes.from_string('public') + 'admin'
        end.to raise_error(NoMethodError)
      end
    end

    describe '#&' do
      it 'can get intersection with another scope object' do
        scopes = Scopes.from_string('public admin') & Scopes.from_string('write admin')
        expect(scopes.all).to eq(%w[admin])
      end

      it 'does not change the existing object' do
        origin = Scopes.from_string('public admin')
        origin & Scopes.from_string('write admin')
        expect(origin.to_s).to eq('public admin')
      end

      it 'can get intersection with an array' do
        scopes = Scopes.from_string('public admin') & %w[write admin]
        expect(scopes.all).to eq(%w[admin])
      end
    end

    describe '#==' do
      it 'is equal to another set of scopes' do
        expect(Scopes.from_string('public')).to eq(Scopes.from_string('public'))
      end

      it 'is equal to another set of scopes with no particular order' do
        expect(Scopes.from_string('public write')).to eq(Scopes.from_string('write public'))
      end

      it 'differs from another set of scopes when scopes are not the same' do
        expect(Scopes.from_string('public write')).not_to eq(Scopes.from_string('write'))
      end

      it "does not raise an error when compared to a non-enumerable object" do
        expect { Scopes.from_string("public") == false }.not_to raise_error
      end
    end

    describe '#has_scopes?' do
      subject { Scopes.from_string('public admin') }

      it 'returns true when at least one scope is included' do
        expect(subject.has_scopes?(Scopes.from_string('public'))).to be_truthy
      end

      it 'returns true when all scopes are included' do
        expect(subject.has_scopes?(Scopes.from_string('public admin'))).to be_truthy
      end

      it 'is true if all scopes are included in any order' do
        expect(subject.has_scopes?(Scopes.from_string('admin public'))).to be_truthy
      end

      it 'is false if no scopes are included' do
        expect(subject.has_scopes?(Scopes.from_string('notexistent'))).to be_falsey
      end

      it 'returns false when any scope is not included' do
        expect(subject.has_scopes?(Scopes.from_string('public nope'))).to be_falsey
      end

      it 'is false if no scopes are included even for existing ones' do
        expect(subject.has_scopes?(Scopes.from_string('public admin notexistent'))).to be_falsey
      end
    end
  end
end
