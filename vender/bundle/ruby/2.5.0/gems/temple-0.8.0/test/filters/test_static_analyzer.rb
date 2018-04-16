require 'helper'

describe Temple::Filters::StaticAnalyzer do
  before do
    @filter = Temple::Filters::StaticAnalyzer.new
    @generator = Temple::Generator.new
  end

  if Temple::StaticAnalyzer.available?
    it 'should convert :dynamic to :static if code is static' do
      @filter.call([:dynamic, '"#{"hello"}#{100}"']
      ).should.equal [:static, 'hello100']
    end

    it 'should not convert :dynamic if code is dynamic' do
      exp = [:dynamic, '"#{hello}#{100}"']
      @filter.call(exp).should.equal(exp)
    end

    it 'should not change number of newlines in generated code' do
      exp = [:dynamic, "[100,\n200,\n]"]
      @filter.call(exp).should.equal([:multi, [:static, '[100, 200]'], [:newline], [:newline]])

      @generator.call(@filter.call(exp)).count("\n").
        should.equal(@generator.call(exp).count("\n"))
    end
  else
    it 'should do nothing' do
      [
        [:dynamic, '"#{"hello"}#{100}"'],
        [:dynamic, '"#{hello}#{100}"'],
      ].each do |exp|
        @filter.call(exp).should.equal(exp)
      end
    end
  end
end
