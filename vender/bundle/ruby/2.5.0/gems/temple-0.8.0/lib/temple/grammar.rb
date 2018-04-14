module Temple
  # Temple expression grammar which can be used to validate Temple expressions.
  #
  # Example:
  #   Temple::Grammar.match? [:static, 'Valid Temple Expression']
  #   Temple::Grammar.validate! [:multi, 'Invalid Temple Expression']
  #
  # See {file:EXPRESSIONS.md Expression documentation}.
  #
  # @api public
  module Grammar
    extend Mixins::GrammarDSL

    Expression <<
      # Core abstraction
      [:multi, 'Expression*']                  |
      [:static, String]                        |
      [:dynamic, String]                       |
      [:code, String]                          |
      [:capture, String, Expression]           |
      [:newline]                               |
      # Control flow abstraction
      [:if, String, Expression, 'Expression?'] |
      [:block, String, Expression]             |
      [:case, String, 'Case*']                 |
      [:cond, 'Case*']                         |
      # Escape abstraction
      [:escape, Bool, Expression]              |
      # HTML abstraction
      [:html, :doctype, String]                |
      [:html, :comment, Expression]            |
      [:html, :condcomment, String, Expression]|
      [:html, :js, Expression]                 |
      [:html, :tag, HTMLIdentifier, Expression, 'Expression?'] |
      [:html, :attrs, 'HTMLAttr*']             |
      HTMLAttr

    EmptyExp <<
      [:newline] | [:multi, 'EmptyExp*']

    HTMLAttr <<
      [:html, :attr, HTMLIdentifier, Expression]

    HTMLIdentifier <<
      Symbol | String

    Case <<
      [Condition, Expression]

    Condition <<
      String | :else

    Bool <<
      true | false

  end
end
