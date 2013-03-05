module Debugger
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
end
