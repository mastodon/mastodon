# encoding: utf-8

# Includes tests based on Simon Sapin's CSS parsing tests:
# https://github.com/SimonSapin/css-parsing-tests/

shared_tests_for 'parsing a list of rules' do
  it 'should parse an empty stylesheet' do
    assert_equal([], parse(''))
    assert_equal([{:node=>:error, :value=>"invalid"}], parse('foo'))
    assert_equal([{:node=>:error, :value=>"invalid"}], parse('foo 4'))
  end

  describe 'should parse an at-rule' do
    describe 'without a block' do
      it 'without a prelude' do
        tree = parse('@foo')

        assert_equal([
          {:node=>:at_rule,
            :name=>"foo",
            :prelude=>[],
            :tokens=>[{:node=>:at_keyword, :pos=>0, :raw=>"@foo", :value=>"foo"}]}
        ], tree)
      end

      it 'with a prelude followed by a comment' do
        tree = parse("@foo bar; \t/* comment */")

        assert_equal([
          {:node=>:at_rule,
            :name=>"foo",
            :prelude=>
             [{:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:ident, :pos=>5, :raw=>"bar", :value=>"bar"}],
            :tokens=>
             [{:node=>:at_keyword, :pos=>0, :raw=>"@foo", :value=>"foo"},
              {:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:ident, :pos=>5, :raw=>"bar", :value=>"bar"},
              {:node=>:semicolon, :pos=>8, :raw=>";"}]},
           {:node=>:whitespace, :pos=>9, :raw=>" \t"}
        ], tree)
      end

      it 'with a prelude followed by a comment, when :preserve_comments == true' do
        options = {:preserve_comments => true}
        tree    = parse("@foo bar; \t/* comment */", options)

        assert_equal([
          {:node=>:at_rule,
            :name=>"foo",
            :prelude=>
             [{:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:ident, :pos=>5, :raw=>"bar", :value=>"bar"}],
            :tokens=>
             [{:node=>:at_keyword, :pos=>0, :raw=>"@foo", :value=>"foo"},
              {:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:ident, :pos=>5, :raw=>"bar", :value=>"bar"},
              {:node=>:semicolon, :pos=>8, :raw=>";"}]},
          {:node=>:whitespace, :pos=>9, :raw=>" \t"},
          {:node=>:comment, :pos=>11, :raw=>"/* comment */", :value=>" comment "}
        ], tree)
      end

      it 'with a prelude containing a simple block' do
        tree = parse("@foo [ bar")

        assert_equal([
          {:node=>:at_rule,
            :name=>"foo",
            :prelude=>
             [{:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:simple_block,
               :start=>"[",
               :end=>"]",
               :value=>
                [{:node=>:whitespace, :pos=>6, :raw=>" "},
                 {:node=>:ident, :pos=>7, :raw=>"bar", :value=>"bar"}],
               :tokens=>
                [{:node=>:"[", :pos=>5, :raw=>"["},
                 {:node=>:whitespace, :pos=>6, :raw=>" "},
                 {:node=>:ident, :pos=>7, :raw=>"bar", :value=>"bar"}]}],
            :tokens=>
             [{:node=>:at_keyword, :pos=>0, :raw=>"@foo", :value=>"foo"},
              {:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:"[", :pos=>5, :raw=>"["},
              {:node=>:whitespace, :pos=>6, :raw=>" "},
              {:node=>:ident, :pos=>7, :raw=>"bar", :value=>"bar"}]}
        ], tree)
      end
    end

    describe 'with a block' do
      it 'unclosed' do
        tree = parse("@foo { bar")

        assert_equal([
          {:node=>:at_rule,
            :name=>"foo",
            :prelude=>[{:node=>:whitespace, :pos=>4, :raw=>" "}],
            :block=>
             [{:node=>:whitespace, :pos=>6, :raw=>" "},
              {:node=>:ident, :pos=>7, :raw=>"bar", :value=>"bar"}],
            :tokens=>
             [{:node=>:at_keyword, :pos=>0, :raw=>"@foo", :value=>"foo"},
              {:node=>:whitespace, :pos=>4, :raw=>" "},
              {:node=>:"{", :pos=>5, :raw=>"{"},
              {:node=>:whitespace, :pos=>6, :raw=>" "},
              {:node=>:ident, :pos=>7, :raw=>"bar", :value=>"bar"}]}
        ], tree)
      end

      it 'unclosed, preceded by a comment' do
        tree = parse(" /**/ @foo bar{[(4")

        assert_equal([
          {:node=>:whitespace, :pos=>0, :raw=>" "},
          {:node=>:whitespace, :pos=>5, :raw=>" "},
          {:node=>:at_rule,
           :name=>"foo",
           :prelude=>
            [{:node=>:whitespace, :pos=>10, :raw=>" "},
             {:node=>:ident, :pos=>11, :raw=>"bar", :value=>"bar"}],
           :block=>
            [{:node=>:simple_block,
              :start=>"[",
              :end=>"]",
              :value=>
               [{:node=>:simple_block,
                 :start=>"(",
                 :end=>")",
                 :value=>
                  [{:node=>:number,
                    :pos=>17,
                    :raw=>"4",
                    :repr=>"4",
                    :type=>:integer,
                    :value=>4}],
                 :tokens=>
                  [{:node=>:"(", :pos=>16, :raw=>"("},
                   {:node=>:number,
                    :pos=>17,
                    :raw=>"4",
                    :repr=>"4",
                    :type=>:integer,
                    :value=>4}]}],
              :tokens=>
               [{:node=>:"[", :pos=>15, :raw=>"["},
                {:node=>:"(", :pos=>16, :raw=>"("},
                {:node=>:number,
                 :pos=>17,
                 :raw=>"4",
                 :repr=>"4",
                 :type=>:integer,
                 :value=>4}]}],
           :tokens=>
            [{:node=>:at_keyword, :pos=>6, :raw=>"@foo", :value=>"foo"},
             {:node=>:whitespace, :pos=>10, :raw=>" "},
             {:node=>:ident, :pos=>11, :raw=>"bar", :value=>"bar"},
             {:node=>:"{", :pos=>14, :raw=>"{"},
             {:node=>:"[", :pos=>15, :raw=>"["},
             {:node=>:"(", :pos=>16, :raw=>"("},
             {:node=>:number,
              :pos=>17,
              :raw=>"4",
              :repr=>"4",
              :type=>:integer,
              :value=>4}]}
        ], tree)
      end

      it 'unclosed, preceded by a comment, when :preserve_comments == true' do
        options = {:preserve_comments => true}
        tree    = parse(" /**/ @foo bar{[(4", options)

        assert_equal([
          {:node=>:whitespace, :pos=>0, :raw=>" "},
          {:node=>:comment, :pos=>1, :raw=>"/**/", :value=>""},
          {:node=>:whitespace, :pos=>5, :raw=>" "},
          {:node=>:at_rule,
           :name=>"foo",
           :prelude=>
            [{:node=>:whitespace, :pos=>10, :raw=>" "},
             {:node=>:ident, :pos=>11, :raw=>"bar", :value=>"bar"}],
           :block=>
            [{:node=>:simple_block,
              :start=>"[",
              :end=>"]",
              :value=>
               [{:node=>:simple_block,
                 :start=>"(",
                 :end=>")",
                 :value=>
                  [{:node=>:number,
                    :pos=>17,
                    :raw=>"4",
                    :repr=>"4",
                    :type=>:integer,
                    :value=>4}],
                 :tokens=>
                  [{:node=>:"(", :pos=>16, :raw=>"("},
                   {:node=>:number,
                    :pos=>17,
                    :raw=>"4",
                    :repr=>"4",
                    :type=>:integer,
                    :value=>4}]}],
              :tokens=>
               [{:node=>:"[", :pos=>15, :raw=>"["},
                {:node=>:"(", :pos=>16, :raw=>"("},
                {:node=>:number,
                 :pos=>17,
                 :raw=>"4",
                 :repr=>"4",
                 :type=>:integer,
                 :value=>4}]}],
           :tokens=>
            [{:node=>:at_keyword, :pos=>6, :raw=>"@foo", :value=>"foo"},
             {:node=>:whitespace, :pos=>10, :raw=>" "},
             {:node=>:ident, :pos=>11, :raw=>"bar", :value=>"bar"},
             {:node=>:"{", :pos=>14, :raw=>"{"},
             {:node=>:"[", :pos=>15, :raw=>"["},
             {:node=>:"(", :pos=>16, :raw=>"("},
             {:node=>:number,
              :pos=>17,
              :raw=>"4",
              :repr=>"4",
              :type=>:integer,
              :value=>4}]}
        ], tree)
      end

    end
  end

  describe 'should parse a style rule' do
    it 'with preceding comment, selector, block, comment' do
      tree = parse(" /**/ div > p { color: #aaa;  } /**/ ")

      assert_equal([
        {:node=>:whitespace, :pos=>0, :raw=>" "},
        {:node=>:whitespace, :pos=>5, :raw=>" "},
        {:node=>:style_rule,
         :selector=>
          {:node=>:selector,
           :value=>"div > p",
           :tokens=>
            [{:node=>:ident, :pos=>6, :raw=>"div", :value=>"div"},
             {:node=>:whitespace, :pos=>9, :raw=>" "},
             {:node=>:delim, :pos=>10, :raw=>">", :value=>">"},
             {:node=>:whitespace, :pos=>11, :raw=>" "},
             {:node=>:ident, :pos=>12, :raw=>"p", :value=>"p"},
             {:node=>:whitespace, :pos=>13, :raw=>" "}]},
         :children=>
          [{:node=>:whitespace, :pos=>15, :raw=>" "},
           {:node=>:property,
            :name=>"color",
            :value=>"#aaa",
            :children=>
             [{:node=>:whitespace, :pos=>22, :raw=>" "},
              {:node=>:hash, :pos=>23, :raw=>"#aaa", :type=>:id, :value=>"aaa"}],
            :important=>false,
            :tokens=>
             [{:node=>:ident, :pos=>16, :raw=>"color", :value=>"color"},
              {:node=>:colon, :pos=>21, :raw=>":"},
              {:node=>:whitespace, :pos=>22, :raw=>" "},
              {:node=>:hash, :pos=>23, :raw=>"#aaa", :type=>:id, :value=>"aaa"}]},
           {:node=>:semicolon, :pos=>27, :raw=>";"},
           {:node=>:whitespace, :pos=>28, :raw=>"  "}]},
        {:node=>:whitespace, :pos=>31, :raw=>" "},
        {:node=>:whitespace, :pos=>36, :raw=>" "}
      ], tree)
    end

    it 'with preceding comment, selector, block, comment, when :preserve_comments == true' do
      options = {:preserve_comments => true}
      tree    = parse(" /**/ div > p { color: #aaa;  } /**/ ", options)

      assert_equal([
        {:node=>:whitespace, :pos=>0, :raw=>" "},
        {:node=>:comment, :pos=>1, :raw=>"/**/", :value=>""},
        {:node=>:whitespace, :pos=>5, :raw=>" "},
        {:node=>:style_rule,
         :selector=>
          {:node=>:selector,
           :value=>"div > p",
           :tokens=>
            [{:node=>:ident, :pos=>6, :raw=>"div", :value=>"div"},
             {:node=>:whitespace, :pos=>9, :raw=>" "},
             {:node=>:delim, :pos=>10, :raw=>">", :value=>">"},
             {:node=>:whitespace, :pos=>11, :raw=>" "},
             {:node=>:ident, :pos=>12, :raw=>"p", :value=>"p"},
             {:node=>:whitespace, :pos=>13, :raw=>" "}]},
         :children=>
          [{:node=>:whitespace, :pos=>15, :raw=>" "},
           {:node=>:property,
            :name=>"color",
            :value=>"#aaa",
            :children=>
             [{:node=>:whitespace, :pos=>22, :raw=>" "},
              {:node=>:hash, :pos=>23, :raw=>"#aaa", :type=>:id, :value=>"aaa"}],
            :important=>false,
            :tokens=>
             [{:node=>:ident, :pos=>16, :raw=>"color", :value=>"color"},
              {:node=>:colon, :pos=>21, :raw=>":"},
              {:node=>:whitespace, :pos=>22, :raw=>" "},
              {:node=>:hash, :pos=>23, :raw=>"#aaa", :type=>:id, :value=>"aaa"}]},
           {:node=>:semicolon, :pos=>27, :raw=>";"},
           {:node=>:whitespace, :pos=>28, :raw=>"  "}]},
        {:node=>:whitespace, :pos=>31, :raw=>" "},
        {:node=>:comment, :pos=>32, :raw=>"/**/", :value=>""},
        {:node=>:whitespace, :pos=>36, :raw=>" "}
      ], tree)
    end
  end

  it 'should parse property values containing functions' do
    tree = parse("p:before { content: a\\ttr(data-foo) \" \"; }")

    assert_equal([
      {:node=>:style_rule,
        :selector=>
         {:node=>:selector,
          :value=>"p:before",
          :tokens=>
           [{:node=>:ident, :pos=>0, :raw=>"p", :value=>"p"},
            {:node=>:colon, :pos=>1, :raw=>":"},
            {:node=>:ident, :pos=>2, :raw=>"before", :value=>"before"},
            {:node=>:whitespace, :pos=>8, :raw=>" "}]},
        :children=>
         [{:node=>:whitespace, :pos=>10, :raw=>" "},
          {:node=>:property,
           :name=>"content",
           :value=>"attr(data-foo) \" \"",
           :children=>
            [{:node=>:whitespace, :pos=>19, :raw=>" "},
             {:node=>:function,
              :name=>"attr",
              :value=>
               [{:node=>:ident, :pos=>26, :raw=>"data-foo", :value=>"data-foo"}],
              :tokens=>
               [{:node=>:function, :pos=>20, :raw=>"a\\ttr(", :value=>"attr"},
                {:node=>:ident, :pos=>26, :raw=>"data-foo", :value=>"data-foo"},
                {:node=>:")", :pos=>34, :raw=>")"}]},
             {:node=>:whitespace, :pos=>35, :raw=>" "},
             {:node=>:string, :pos=>36, :raw=>"\" \"", :value=>" "}],
           :important=>false,
           :tokens=>
            [{:node=>:ident, :pos=>11, :raw=>"content", :value=>"content"},
             {:node=>:colon, :pos=>18, :raw=>":"},
             {:node=>:whitespace, :pos=>19, :raw=>" "},
             {:node=>:function,
              :name=>"attr",
              :value=>
               [{:node=>:ident, :pos=>26, :raw=>"data-foo", :value=>"data-foo"}],
              :tokens=>
               [{:node=>:function, :pos=>20, :raw=>"a\\ttr(", :value=>"attr"},
                {:node=>:ident, :pos=>26, :raw=>"data-foo", :value=>"data-foo"},
                {:node=>:")", :pos=>34, :raw=>")"}]},
             {:node=>:whitespace, :pos=>35, :raw=>" "},
             {:node=>:string, :pos=>36, :raw=>"\" \"", :value=>" "}]},
          {:node=>:semicolon, :pos=>39, :raw=>";"},
          {:node=>:whitespace, :pos=>40, :raw=>" "}]}
    ], tree)
  end

  it 'should parse property values containing nested functions' do
    tree = parse("div { width: e\\78 pression(alert(1)); }")

    assert_equal([
      {:node=>:style_rule,
        :selector=>
         {:node=>:selector,
          :value=>"div",
          :tokens=>
           [{:node=>:ident, :pos=>0, :raw=>"div", :value=>"div"},
            {:node=>:whitespace, :pos=>3, :raw=>" "}]},
        :children=>
         [{:node=>:whitespace, :pos=>5, :raw=>" "},
          {:node=>:property,
           :name=>"width",
           :value=>"expression(alert(1))",
           :children=>
            [{:node=>:whitespace, :pos=>12, :raw=>" "},
             {:node=>:function,
              :name=>"expression",
              :value=>
               [{:node=>:function,
                 :name=>"alert",
                 :value=>
                  [{:node=>:number,
                    :pos=>33,
                    :raw=>"1",
                    :repr=>"1",
                    :type=>:integer,
                    :value=>1}],
                 :tokens=>
                  [{:node=>:function, :pos=>27, :raw=>"alert(", :value=>"alert"},
                   {:node=>:number,
                    :pos=>33,
                    :raw=>"1",
                    :repr=>"1",
                    :type=>:integer,
                    :value=>1},
                   {:node=>:")", :pos=>34, :raw=>")"}]}],
              :tokens=>
               [{:node=>:function,
                 :pos=>13,
                 :raw=>"e\\78 pression(",
                 :value=>"expression"},
                {:node=>:function, :pos=>27, :raw=>"alert(", :value=>"alert"},
                {:node=>:number,
                 :pos=>33,
                 :raw=>"1",
                 :repr=>"1",
                 :type=>:integer,
                 :value=>1},
                {:node=>:")", :pos=>34, :raw=>")"},
                {:node=>:")", :pos=>35, :raw=>")"}]}],
           :important=>false,
           :tokens=>
            [{:node=>:ident, :pos=>6, :raw=>"width", :value=>"width"},
             {:node=>:colon, :pos=>11, :raw=>":"},
             {:node=>:whitespace, :pos=>12, :raw=>" "},
             {:node=>:function,
              :name=>"expression",
              :value=>
               [{:node=>:function,
                 :name=>"alert",
                 :value=>
                  [{:node=>:number,
                    :pos=>33,
                    :raw=>"1",
                    :repr=>"1",
                    :type=>:integer,
                    :value=>1}],
                 :tokens=>
                  [{:node=>:function, :pos=>27, :raw=>"alert(", :value=>"alert"},
                   {:node=>:number,
                    :pos=>33,
                    :raw=>"1",
                    :repr=>"1",
                    :type=>:integer,
                    :value=>1},
                   {:node=>:")", :pos=>34, :raw=>")"}]}],
              :tokens=>
               [{:node=>:function,
                 :pos=>13,
                 :raw=>"e\\78 pression(",
                 :value=>"expression"},
                {:node=>:function, :pos=>27, :raw=>"alert(", :value=>"alert"},
                {:node=>:number,
                 :pos=>33,
                 :raw=>"1",
                 :repr=>"1",
                 :type=>:integer,
                 :value=>1},
                {:node=>:")", :pos=>34, :raw=>")"},
                {:node=>:")", :pos=>35, :raw=>")"}]}]},
          {:node=>:semicolon, :pos=>36, :raw=>";"},
          {:node=>:whitespace, :pos=>37, :raw=>" "}]}
    ], tree)
  end
end
