module Debugger
  class TraceCommand < Command

    def execute_with_xml(*args)
      errmsg(pr("general.errors.unsupported", cmd: 'trace')) && return if Debugger.printer.type == "xml"
      execute_without_xml(*args)
    end

    alias_method :execute_without_xml, :execute
    alias_method :execute, :execute_with_xml

  end
end
