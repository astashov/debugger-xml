module Byebug
  module VarFunctions # :nodoc:

    def var_global
      var_list(global_variables.reject { |v| [:$=, :$KCODE, :$-K, :$FILENAME].include?(v) })
    end

  end
  class VarInstanceCommand < Command

    def execute_with_xml(*args)
      if Byebug.printer.type == "xml"
        DebuggerXml.logger.puts("match: #{@match}")
        DebuggerXml.logger.puts("THE OBJ: #{get_obj(@match).inspect}")
        print Byebug.printer.print_instance_variables(get_obj(@match))
      else
        execute_without_xml(*args)
      end
    end

    alias_method :execute_without_xml, :execute
    alias_method :execute, :execute_with_xml

    private

    def get_obj(match)
      if match[1]
        begin
          DebuggerXml.logger.puts("Getting object space")
          ObjectSpace._id2ref(match[1].hex)
        rescue RangeError
          errmsg "Unknown object id : %s" % match[1]
          nil
        end
      else
        bb_warning_eval(match.post_match.empty? ? 'self' : match.post_match)
      end
    end
  end

  class VarIdeCommand < Command
    def regexp
      /^\s*v(?:ar)?\s+ide\s*$/
    end

    def execute
      locals = []
      _self = @state.context.frame_self(@state.frame_pos)
      locals << ['self', _self] unless _self.to_s == "main"
      locals += @state.context.frame_locals(@state.frame_pos).sort.map { |key, value| [key, value] }
      print prv(locals, 'instance')
    end
  end
end
