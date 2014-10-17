module Debugger
  module VarFunctions # :nodoc:

    def var_global
      var_list(global_variables.reject { |v| [:$=, :$KCODE, :$-K, :$FILENAME].include?(v) })
    end

  end
  class VarInstanceCommand < Command

    def execute_with_xml(*args)
      if Debugger.printer.type == "xml"
        print Debugger.printer.print_instance_variables(get_obj(@match))
      else
        execute_without_xml(*args)
      end
    end

    alias_method :execute_without_xml, :execute
    alias_method :execute, :execute_with_xml

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
