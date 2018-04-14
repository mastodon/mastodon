require 'spec_helper'

describe Chewy::Type::Adapter::Object do
  before { stub_class(:product) }
  subject { described_class.new(:product) }

  describe '#name' do
    specify { expect(described_class.new('product').name).to eq('Product') }
    specify { expect(described_class.new(:products).name).to eq('Products') }
    specify { expect(described_class.new(Product).name).to eq('Product') }
    specify { expect(described_class.new(Product, name: 'house').name).to eq('House') }

    context do
      before { stub_class('namespace/product') }

      specify { expect(described_class.new(Namespace::Product).name).to eq('Product') }
    end
  end

  describe '#type_name' do
    specify { expect(described_class.new('product').type_name).to eq('product') }
    specify { expect(described_class.new(:products).type_name).to eq('products') }
    specify { expect(described_class.new(Product).type_name).to eq('product') }
    specify { expect(described_class.new(Product, name: 'house').type_name).to eq('house') }

    context do
      before { stub_class('namespace/product') }

      specify { expect(described_class.new(Namespace::Product).type_name).to eq('product') }
    end
  end

  describe '#identify' do
    let!(:objects) { Array.new(3) { double } }

    specify { expect(subject.identify(objects)).to eq(objects) }
    specify { expect(subject.identify(objects.first)).to eq([objects.first]) }
  end

  describe '#import' do
    def import(*args)
      result = []
      subject.import(*args) { |data| result.push data }
      result
    end

    specify { expect(subject.import(Array.new(3) { double }) { |_data| true }).to eq(true) }
    specify { expect(subject.import(Array.new(3) { double }) { |_data| false }).to eq(false) }

    context do
      let(:objects) { Array.new(3) { double } }
      let(:deleted) { Array.new(2) { double(destroyed?: true) } }
      subject { described_class.new('product') }

      specify { expect(import).to eq([]) }
      specify { expect(import(nil)).to eq([]) }

      specify { expect(import(objects)).to eq([{index: objects}]) }
      specify do
        expect(import(objects, batch_size: 2))
          .to eq([{index: objects.first(2)}, {index: objects.last(1)}])
      end
      specify { expect(import(objects, deleted)).to eq([{index: objects, delete: deleted}]) }
      specify do
        expect(import(objects, deleted, batch_size: 2)).to eq([
          {index: objects.first(2)},
          {index: objects.last(1), delete: deleted.first(1)},
          {delete: deleted.last(1)}
        ])
      end

      specify { expect(import(objects.first, nil)).to eq([{index: [objects.first]}]) }

      context 'initial data' do
        subject { described_class.new -> { objects } }

        specify { expect(import).to eq([{index: objects}]) }
        specify { expect(import(nil)).to eq([]) }

        specify { expect(import(objects[0..1])).to eq([{index: objects[0..1]}]) }
        specify do
          expect(import(batch_size: 2))
            .to eq([{index: objects.first(2)}, {index: objects.last(1)}])
        end
      end

      context do
        subject { described_class.new('product', delete_if: :delete?) }
        let(:deleted) do
          [
            double(delete?: true, destroyed?: true),
            double(delete?: true, destroyed?: false),
            double(delete?: false, destroyed?: true),
            double(delete?: false, destroyed?: false)
          ]
        end

        specify do
          expect(import(deleted)).to eq([
            {delete: deleted[0..2], index: deleted.last(1)}
          ])
        end
      end
    end

    context 'error handling' do
      let(:products) { Array.new(3) { |i| double.tap { |product| allow(product).to receive_messages(rating: i.next) } } }
      let(:deleted) { Array.new(2) { |i| double(destroyed?: true, rating: i + 4) } }
      subject { described_class.new('product') }

      let(:data_comparer) do
        ->(n, data) { (data[:index] || data[:delete]).first.rating != n }
      end

      specify { expect(subject.import(products, deleted) { |_data| true }).to eq(true) }
      specify { expect(subject.import(products, deleted) { |_data| false }).to eq(false) }
      specify { expect(subject.import(products, deleted, batch_size: 1, &data_comparer.curry[1])).to eq(false) }
      specify { expect(subject.import(products, deleted, batch_size: 1, &data_comparer.curry[2])).to eq(false) }
      specify { expect(subject.import(products, deleted, batch_size: 1, &data_comparer.curry[3])).to eq(false) }
      specify { expect(subject.import(products, deleted, batch_size: 1, &data_comparer.curry[4])).to eq(false) }
      specify { expect(subject.import(products, deleted, batch_size: 1, &data_comparer.curry[5])).to eq(false) }
    end
  end

  describe '#import_fields' do
    let!(:objects) { Array.new(3) { |i| double(id: i + 1, name: "Name#{i}") } }
    let!(:hashes) { Array.new(3) { |i| {id: i + 1, 'name' => "Name#{i}"} } }

    context do
      subject { described_class.new(-> { objects }) }
      specify { expect(subject.import_fields).to match([[1, 2, 3]]) }
      specify { expect(subject.import_fields(fields: [:name])).to match([[[1, 'Name0'], [2, 'Name1'], [3, 'Name2']]]) }
    end

    context do
      subject { described_class.new(-> { objects }) }
      specify { expect(subject.import_fields(batch_size: 2)).to match([[1, 2], [3]]) }
      specify { expect(subject.import_fields(fields: [:name], batch_size: 2)).to match([[[1, 'Name0'], [2, 'Name1']], [[3, 'Name2']]]) }
    end

    context do
      subject { described_class.new(-> { objects }) }
      specify { expect(subject.import_fields(objects.first(2))).to match([[1, 2]]) }
      specify { expect(subject.import_fields(objects.first(2), fields: [:name])).to match([[[1, 'Name0'], [2, 'Name1']]]) }
    end

    context do
      subject { described_class.new(-> { hashes }) }
      specify { expect(subject.import_fields).to match([[1, 2, 3]]) }
      specify { expect(subject.import_fields(fields: [:name])).to match([[[1, 'Name0'], [2, 'Name1'], [3, 'Name2']]]) }
    end

    context do
      subject { described_class.new(-> { [1, 2, 3] }) }
      specify { expect(subject.import_fields).to match([[1, 2, 3]]) }
      specify { expect(subject.import_fields(fields: [:name])).to match([[[1, nil], [2, nil], [3, nil]]]) }
    end

    context do
      before do
        stub_class(:product) do
          def self.pluck(*fields)
            if fields == [:id]
              [1, 2, 3]
            elsif fields.size > 1
              [4, 5, 6]
            end
          end
        end
      end

      context do
        subject { described_class.new(Product) }
        specify { expect(subject.import_fields).to match([[1, 2, 3]]) }
        specify { expect(subject.import_fields(fields: [:name])).to match([[4, 5, 6]]) }
      end

      context do
        subject { described_class.new(Product) }
        specify { expect(subject.import_fields(objects.first(2))).to match([[1, 2]]) }
        specify { expect(subject.import_fields(objects.first(2), fields: [:name])).to match([[[1, 'Name0'], [2, 'Name1']]]) }
      end

      context 'batch_size' do
        subject { described_class.new(Product) }
        specify { expect(subject.import_fields(batch_size: 2)).to match([[1, 2], [3]]) }
        specify { expect(subject.import_fields(fields: [:name], batch_size: 2)).to match([[4, 5], [6]]) }
      end
    end
  end

  describe '#import_references' do
    let!(:objects) { Array.new(3) { |i| double(id: i + 1, name: "Name#{i}") } }

    subject { described_class.new(-> { objects }) }
    specify { expect(subject.import_references).to match([objects]) }
    specify { expect(subject.import_references(batch_size: 2)).to match([objects.first(2), objects.last(1)]) }
    specify { expect(subject.import_references(objects.first(2))).to match([objects.first(2)]) }
    specify { expect(subject.import_references(objects.first(2), batch_size: 1)).to match([objects.first(1), [objects[1]]]) }
  end

  describe '#load' do
    subject { described_class.new(Product) }
    let(:objects) { (1..3).to_a }

    specify { expect(subject.load(objects)).to be_nil }

    context do
      before { allow(Product).to receive(:load_all) { |objects| objects.map { |i| i * 3 } } }
      specify { expect(subject.load(objects, value: 42)).to eq([3, 6, 9]) }
    end

    context do
      before { allow(Product).to receive(:load_all) { |objects, options| objects.map { |i| i * options[:value] } } }
      specify { expect(subject.load(objects, value: 2)).to eq([2, 4, 6]) }
    end

    context do
      before { allow(Product).to receive(:load_one) { |object| object + 2 } }
      specify { expect(subject.load(objects)).to eq((3..5).to_a) }
    end

    context do
      before { allow(Product).to receive(:load_one) { |object, options| object + options[:value] } }
      specify { expect(subject.load(objects, value: 42)).to eq((43..45).to_a) }
    end
  end
end
