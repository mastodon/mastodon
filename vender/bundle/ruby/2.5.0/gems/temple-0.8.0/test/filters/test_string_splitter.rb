require 'helper'
begin
  require 'ripper'
rescue LoadError
end

if defined?(Ripper) && RUBY_VERSION >= "2.0.0"
  describe Temple::Filters::StringSplitter do
    before do
      @filter = Temple::Filters::StringSplitter.new
    end

    it 'should split :dynamic with string literal' do
      @filter.call([:dynamic, '"static#{dynamic}"']
      ).should.equal [:multi, [:static, 'static'], [:dynamic, 'dynamic']]
    end

    describe '.compile' do
      it 'should raise CompileError for non-string literals' do
        lambda { Temple::Filters::StringSplitter.compile('1') }.
          should.raise(Temple::FilterError)
      end
    end
  end
end
