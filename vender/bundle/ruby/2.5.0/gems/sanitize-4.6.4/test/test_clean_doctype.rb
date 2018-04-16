# encoding: utf-8
require_relative 'common'

describe 'Sanitize::Transformers::CleanDoctype' do
  make_my_diffs_pretty!
  parallelize_me!

  describe 'when :allow_doctype is false' do
    before do
      @s = Sanitize.new(:allow_doctype => false, :elements => ['html'])
    end

    it 'should remove doctype declarations' do
      @s.document('<!DOCTYPE html><html>foo</html>').must_equal "<html>foo</html>\n"
      @s.fragment('<!DOCTYPE html>foo').must_equal 'foo'
    end

    it 'should not allow doctype definitions in fragments' do
      @s.fragment('<!DOCTYPE html><html>foo</html>')
        .must_equal "foo"

      @s.fragment('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"><html>foo</html>')
        .must_equal "foo"

      @s.fragment("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><html>foo</html>")
        .must_equal "foo"
    end
  end

  describe 'when :allow_doctype is true' do
    before do
      @s = Sanitize.new(:allow_doctype => true, :elements => ['html'])
    end

    it 'should allow doctype declarations in documents' do
      @s.document('<!DOCTYPE html><html>foo</html>')
        .must_equal "<!DOCTYPE html>\n<html>foo</html>\n"

      @s.document('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"><html>foo</html>')
        .must_equal "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">\n<html>foo</html>\n"

      @s.document("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><html>foo</html>")
        .must_equal "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html>foo</html>\n"
    end

    it 'should not allow obviously invalid doctype declarations in documents' do
      @s.document('<!DOCTYPE blah blah blah><html>foo</html>')
        .must_equal "<!DOCTYPE html>\n<html>foo</html>\n"

      @s.document('<!DOCTYPE blah><html>foo</html>')
        .must_equal "<!DOCTYPE html>\n<html>foo</html>\n"

      @s.document('<!DOCTYPE html BLAH "-//W3C//DTD HTML 4.01//EN"><html>foo</html>')
        .must_equal "<!DOCTYPE html>\n<html>foo</html>\n"

      @s.document('<!whatever><html>foo</html>')
        .must_equal "<html>foo</html>\n"
    end

    it 'should not allow doctype definitions in fragments' do
      @s.fragment('<!DOCTYPE html><html>foo</html>')
        .must_equal "foo"

      @s.fragment('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"><html>foo</html>')
        .must_equal "foo"

      @s.fragment("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><html>foo</html>")
        .must_equal "foo"
    end
  end
end
