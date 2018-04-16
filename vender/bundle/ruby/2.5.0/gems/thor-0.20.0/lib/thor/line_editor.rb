require "thor/line_editor/basic"
require "thor/line_editor/readline"

class Thor
  module LineEditor
    def self.readline(prompt, options = {})
      best_available.new(prompt, options).readline
    end

    def self.best_available
      [
        Thor::LineEditor::Readline,
        Thor::LineEditor::Basic
      ].detect(&:available?)
    end
  end
end
