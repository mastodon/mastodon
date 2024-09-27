# frozen_string_literal: true

class Admin::Db::SchemaParser
  class Index
    attr_reader :name, :table_name, :columns, :options

    def initialize(name:, table_name:, columns:, options:)
      @name = name
      @table_name = table_name
      @columns = columns
      @options = options
    end
  end

  attr_reader :indexes_by_table

  def initialize(source)
    parse(source)
  end

  private

  def parse(source)
    @indexes_by_table = {}
    queue = [Prism.parse(source).value]
    while (node = queue.shift)
      if node.type == :call_node && node.name == :create_table
        parse_create_table(node)
      elsif node.type == :call_node && node.name == :add_index
        parse_add_index(node)
      else
        queue.concat(node.compact_child_nodes)
      end
    end
  end

  def parse_create_table(node)
    table_name = parse_arguments(node).first
    queue = node.compact_child_nodes
    while (node = queue.shift)
      if node.type == :call_node && node.name == :index
        parse_index(node, table_name:)
      else
        queue.concat(node.compact_child_nodes)
      end
    end
  end

  def parse_index(node, table_name:)
    arguments = parse_arguments(node)
    save_index(
      name: arguments.last[:name],
      table_name: table_name,
      columns: arguments.first,
      options: arguments.last
    )
  end

  def parse_add_index(node)
    arguments = parse_arguments(node)
    save_index(
      name: arguments.last[:name],
      table_name: arguments.first,
      columns: arguments[1],
      options: arguments.last
    )
  end

  def parse_arguments(node)
    node.arguments.arguments.map { |a| parse_argument(a) }
  end

  def parse_argument(argument)
    case argument
    when Prism::StringNode
      argument.unescaped
    when Prism::SymbolNode
      argument.unescaped.to_sym
    when Prism::ArrayNode
      argument.elements.map { |e| parse_argument(e) }
    when Prism::KeywordHashNode
      argument.elements.to_h do |element|
        [element.key.unescaped.to_sym, parse_argument(element.value)]
      end
    end
  end

  def save_index(name:, table_name:, columns:, options:)
    @indexes_by_table[table_name] ||= []
    @indexes_by_table[table_name] << Index.new(name:, table_name:, columns:, options:)
  end
end
