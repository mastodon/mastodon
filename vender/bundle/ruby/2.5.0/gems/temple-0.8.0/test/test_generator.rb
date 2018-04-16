require 'helper'

class SimpleGenerator < Temple::Generator
  def preamble
    "#{buffer} = BUFFER"
  end

  def postamble
    buffer
  end

  def on_static(s)
    concat "S:#{s}"
  end

  def on_dynamic(s)
    concat "D:#{s}"
  end

  def on_code(s)
    "C:#{s}"
  end
end

describe Temple::Generator do
  it 'should compile simple expressions' do
    gen = SimpleGenerator.new

    gen.call([:static,  'test']).should.equal '_buf = BUFFER; _buf << (S:test); _buf'
    gen.call([:dynamic, 'test']).should.equal '_buf = BUFFER; _buf << (D:test); _buf'
    gen.call([:code,    'test']).should.equal '_buf = BUFFER; C:test; _buf'
  end

  it 'should compile multi expression' do
    gen = SimpleGenerator.new(buffer: "VAR")
    gen.call([:multi,
      [:static, "static"],
      [:dynamic, "dynamic"],
      [:code, "code"]
    ]).should.equal 'VAR = BUFFER; VAR << (S:static); VAR << (D:dynamic); C:code; VAR'
  end

  it 'should compile capture' do
    gen = SimpleGenerator.new(buffer: "VAR", capture_generator: SimpleGenerator)
    gen.call([:capture, "foo",
      [:static, "test"]
    ]).should.equal 'VAR = BUFFER; foo = BUFFER; foo << (S:test); foo; VAR'
  end

  it 'should compile capture with multi' do
    gen = SimpleGenerator.new(buffer: "VAR", capture_generator: SimpleGenerator)
    gen.call([:multi,
      [:static, "before"],

      [:capture, "foo", [:multi,
        [:static, "static"],
        [:dynamic, "dynamic"],
        [:code, "code"]]],

      [:static, "after"]
    ]).should.equal 'VAR = BUFFER; VAR << (S:before); foo = BUFFER; foo << (S:static); ' +
      'foo << (D:dynamic); C:code; foo; VAR << (S:after); VAR'
  end

  it 'should compile newlines' do
    gen = SimpleGenerator.new(buffer: "VAR")
    gen.call([:multi,
      [:static, "static"],
      [:newline],
      [:dynamic, "dynamic"],
      [:newline],
      [:code, "code"]
    ]).should.equal "VAR = BUFFER; VAR << (S:static); \n; " +
      "VAR << (D:dynamic); \n; C:code; VAR"
  end
end

describe Temple::Generators::Array do
  it 'should compile simple expressions' do
    gen = Temple::Generators::Array.new(freeze_static: false)
    gen.call([:static,  'test']).should.equal '_buf = []; _buf << ("test"); _buf'
    gen.call([:dynamic, 'test']).should.equal '_buf = []; _buf << (test); _buf'
    gen.call([:code,    'test']).should.equal '_buf = []; test; _buf'

    gen.call([:multi, [:static, 'a'], [:static,  'b']]).should.equal '_buf = []; _buf << ("a"); _buf << ("b"); _buf'
    gen.call([:multi, [:static, 'a'], [:dynamic, 'b']]).should.equal '_buf = []; _buf << ("a"); _buf << (b); _buf'
  end

  it 'should freeze static' do
    gen = Temple::Generators::Array.new(freeze_static: true)
    gen.call([:static,  'test']).should.equal '_buf = []; _buf << ("test".freeze); _buf'
  end
end

describe Temple::Generators::ArrayBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::ArrayBuffer.new(freeze_static: false)
    gen.call([:static,  'test']).should.equal '_buf = "test"'
    gen.call([:dynamic, 'test']).should.equal '_buf = (test).to_s'
    gen.call([:code,    'test']).should.equal '_buf = []; test; _buf = _buf.join("")'

    gen.call([:multi, [:static, 'a'], [:static,  'b']]).should.equal '_buf = []; _buf << ("a"); _buf << ("b"); _buf = _buf.join("")'
    gen.call([:multi, [:static, 'a'], [:dynamic, 'b']]).should.equal '_buf = []; _buf << ("a"); _buf << (b); _buf = _buf.join("")'
  end

  it 'should freeze static' do
    gen = Temple::Generators::ArrayBuffer.new(freeze_static: true)
    gen.call([:static,  'test']).should.equal '_buf = "test"'
    gen.call([:multi, [:dynamic, '1'], [:static,  'test']]).should.equal '_buf = []; _buf << (1); _buf << ("test".freeze); _buf = _buf.join("".freeze)'
  end
end

describe Temple::Generators::StringBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::StringBuffer.new(freeze_static: false)
    gen.call([:static,  'test']).should.equal '_buf = "test"'
    gen.call([:dynamic, 'test']).should.equal '_buf = (test).to_s'
    gen.call([:code,    'test']).should.equal '_buf = \'\'; test; _buf'

    gen.call([:multi, [:static, 'a'], [:static,  'b']]).should.equal '_buf = \'\'; _buf << ("a"); _buf << ("b"); _buf'
    gen.call([:multi, [:static, 'a'], [:dynamic, 'b']]).should.equal '_buf = \'\'; _buf << ("a"); _buf << ((b).to_s); _buf'
  end

  it 'should freeze static' do
    gen = Temple::Generators::StringBuffer.new(freeze_static: true)
    gen.call([:static,  'test']).should.equal '_buf = "test"'
    gen.call([:multi, [:dynamic, '1'], [:static,  'test']]).should.equal '_buf = \'\'; _buf << ((1).to_s); _buf << ("test".freeze); _buf'
  end
end

describe Temple::Generators::ERB do
  it 'should compile simple expressions' do
    gen = Temple::Generators::ERB.new
    gen.call([:static,  'test']).should.equal 'test'
    gen.call([:dynamic, 'test']).should.equal '<%= test %>'
    gen.call([:code,    'test']).should.equal '<% test %>'

    gen.call([:multi, [:static, 'a'], [:static,  'b']]).should.equal 'ab'
    gen.call([:multi, [:static, 'a'], [:dynamic, 'b']]).should.equal 'a<%= b %>'
  end
end

describe Temple::Generators::RailsOutputBuffer do
  it 'should compile simple expressions' do
    gen = Temple::Generators::RailsOutputBuffer.new(freeze_static: false)
    gen.call([:static,  'test']).should.equal '@output_buffer = ActiveSupport::SafeBuffer.new; ' +
      '@output_buffer.safe_concat(("test")); @output_buffer'
    gen.call([:dynamic, 'test']).should.equal '@output_buffer = ActiveSupport::SafeBuffer.new; ' +
      '@output_buffer.safe_concat(((test).to_s)); @output_buffer'
    gen.call([:code,    'test']).should.equal '@output_buffer = ActiveSupport::SafeBuffer.new; ' +
      'test; @output_buffer'
  end

  it 'should freeze static' do
    gen = Temple::Generators::RailsOutputBuffer.new(freeze_static: true)
    gen.call([:static,  'test']).should.equal '@output_buffer = ActiveSupport::SafeBuffer.new; @output_buffer.safe_concat(("test".freeze)); @output_buffer'
  end
end
