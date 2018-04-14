require 'spec_helper'

describe Chewy::Search::Parameters::Source do
  subject { described_class.new(%i[foo bar]) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq(includes: [], excludes: [], enabled: true) }
    specify { expect(described_class.new(nil).value).to eq(includes: [], excludes: [], enabled: true) }
    specify { expect(described_class.new([:foo, nil]).value).to eq(includes: %w[foo], excludes: [], enabled: true) }
    specify { expect(described_class.new([:foo, 42]).value).to eq(includes: %w[foo 42], excludes: [], enabled: true) }
    specify { expect(described_class.new(false).value).to eq(includes: [], excludes: [], enabled: false) }
    specify { expect(described_class.new(true).value).to eq(includes: [], excludes: [], enabled: true) }
    specify { expect(described_class.new(a: 1).value).to eq(includes: [], excludes: [], enabled: true) }
    specify { expect(described_class.new(includes: :foo).value).to eq(includes: %w[foo], excludes: [], enabled: true) }
    specify { expect(described_class.new(includes: :foo, excludes: 42).value).to eq(includes: %w[foo], excludes: %w[42], enabled: true) }
    specify { expect(described_class.new(includes: :foo, excludes: 42, enabled: false).value).to eq(includes: %w[foo], excludes: %w[42], enabled: true) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: [], excludes: [], enabled: true)
    end

    specify do
      expect { subject.replace!(%i[foo baz]) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo baz], excludes: [], enabled: true)
    end

    specify do
      expect { subject.replace!(excludes: 42) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: [], excludes: %w[42], enabled: true)
    end

    specify do
      expect { subject.replace!(false) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: [], excludes: [], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.replace!(true) }
          .to change { subject.value }
          .from(includes: %w[foo bar], excludes: [], enabled: false)
          .to(includes: [], excludes: [], enabled: true)
      end
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
    end

    specify do
      expect { subject.update!(%i[foo baz]) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar baz], excludes: [], enabled: true)
    end

    specify do
      expect { subject.update!(excludes: 42) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar], excludes: %w[42], enabled: true)
    end

    specify do
      expect { subject.update!(false) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar], excludes: [], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.update!(true) }
          .to change { subject.value }
          .from(includes: %w[foo bar], excludes: [], enabled: false)
          .to(includes: %w[foo bar], excludes: [], enabled: true)
      end
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
    end

    specify do
      expect { subject.merge!(described_class.new(%i[foo baz])) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar baz], excludes: [], enabled: true)
    end

    specify do
      expect { subject.merge!(described_class.new(excludes: 42)) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar], excludes: %w[42], enabled: true)
    end

    specify do
      expect { subject.merge!(described_class.new(:baz).tap { |i| i.update!(false) }) }
        .to change { subject.value }
        .from(includes: %w[foo bar], excludes: [], enabled: true)
        .to(includes: %w[foo bar baz], excludes: [], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.merge!(described_class.new(excludes: :baz).tap { |i| i.update!(true) }) }
          .to change { subject.value }
          .from(includes: %w[foo bar], excludes: [], enabled: false)
          .to(includes: %w[foo bar], excludes: %w[baz], enabled: true)
      end
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(:foo).render).to eq(_source: %w[foo]) }
    specify { expect(described_class.new(excludes: :foo).render).to eq(_source: {excludes: %w[foo]}) }
    specify do
      expect(described_class.new(includes: :foo, excludes: 42).render)
        .to eq(_source: {includes: %w[foo], excludes: %w[42]})
    end

    specify { expect(described_class.new(false).render).to eq(_source: false) }

    context do
      before { subject.update!(false) }
      specify { expect(subject.render).to eq(_source: false) }
    end
  end
end
