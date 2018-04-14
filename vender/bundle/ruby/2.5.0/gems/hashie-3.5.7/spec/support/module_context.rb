shared_context 'included hash module' do
  let!(:dummy_class) do
    klass = Class.new(::Hash)
    klass.send :include, described_class
    klass
  end

  subject do
    dummy_class.new
  end
end
