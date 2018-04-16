# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD
  ##
  # Streaming writer interface.
  #
  # Writes an array of statements serialized in expanded JSON-LD. No provision for turning rdf:first/rest into @list encodings.
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module StreamingWriter
    ##
    # Write out array start, and note not to prepend node-separating ','
    # @return [void] `self`
    def stream_prologue

      # If we were provided a context, or prefixes, use them to compact the output
      @context = case @options[:context]
      when nil then nil
      when Context then @options[:context]
      else Context.parse(@options[:context])
      end

      #log_debug("prologue") {"context: #{context.inspect}"}
      if context
        @output.puts %({"@context": #{context.serialize['@context'].to_json}, "@graph": [)
      else
        @output.puts "["
      end
      self
    end

    ##
    # Write a statement, creating a current node definition, if necessary.
    #
    # Once a new/first statement is seen, terminate the current node definition and compact if provided a context.
    #
    # Also expects all statements in the same context to be contained in a block including all subjects in a block (except for list elements)
    #
    # Note that if list elements are not received in order using the same subject and property, this may cause a bad serialization.
    #
    # @return [void] `self`
    def stream_statement(statement)
      #log_debug("ss") {"state: #{@state.inspect}, stmt: #{statement}"}
      if @current_graph != statement.graph_name
        end_graph
        start_graph(statement.graph_name)
      end

      # If we're writing a list
      @current_node_def ||= {'@id' => statement.subject.to_s}

      if statement.subject.to_s != @current_node_def['@id']
        end_node
        @current_node_def = {'@id' => statement.subject.to_s}
      end

      if statement.predicate == RDF.type
        (@current_node_def['@type'] ||= []) << statement.object.to_s
      else
        pd = (@current_node_def[statement.predicate.to_s] ||= [])

        pd << if statement.object.resource?
          {'@id' => statement.object.to_s}
        else
          lit = {"@value" => statement.object.to_s}
          lit["@type"] = statement.object.datatype.to_s if statement.object.has_datatype?
          lit["@language"] = statement.object.language.to_s if statement.object.has_language?
          lit
        end
      end
      self
    end

    ##
    # Complete open statements
    # @return [void] `self`
    def stream_epilogue
      #log_debug("epilogue") {"state: #{@state.inspect}"}
      end_graph
      if context
        @output.puts "\n]}"
      else
        @output.puts "\n]"
      end
      self
    end

    private
    
    def start_graph(resource)
      #log_debug("start_graph") {"state: #{@state.inspect}, resource: #{resource}"}
      if resource
        @output.puts(",") if [:wrote_node, :wrote_graph].include?(@state)
        @output.puts %({"@id": "#{resource}", "@graph": [)
        @state = :in_graph
      end
      @current_graph = resource
    end

    def end_graph
      #log_debug("end_graph") {"state: #{@state.inspect}, ctx: #{@current_graph}"}
      end_node
      if @current_graph
        @output.write %(]})
        @state = :wrote_graph
      end
    end

    def end_node
      #log_debug("end_node") {"state: #{@state.inspect}, node: #{@current_node_def.to_json}"}
      @output.puts(",") if [:wrote_node, :wrote_graph].include?(@state)
      if @current_node_def
        node_def = if context
          compacted = JSON::LD::API.compact(@current_node_def, context, rename_bnodes: false)
          compacted.delete('@context')
          compacted
        else
          @current_node_def
        end
        @output.write node_def.to_json
        @state = :wrote_node
        @current_node_def = nil
      end
    end
  end
end
