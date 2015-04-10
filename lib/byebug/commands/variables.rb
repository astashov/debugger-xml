module Byebug
  module VarFunctions # :nodoc:

    def var_ide(*args)
      locals = []
      _self = @state.context.frame_self(@state.frame)
      locals << ['self', _self] unless _self.to_s == "main"
      locals += @state.context.frame_locals(@state.frame).sort.map { |key, value| [key, value] }
      print prv(locals, 'instance')
    end

  end
  class VarCommand < Command
    Subcommands << Subcmd.new('ide', 1, 'Shows set of variables for IDE usage')
    Subcommands << Subcmd.new('inspect', 7, 'inspect a given object (supposed to be used only from ide)')

    def var_instance_with_xml(*args)
      if Byebug.printer.type == "xml"
        DebuggerXml.logger.puts("match: #{@match}")
        DebuggerXml.logger.puts("THE OBJ: #{get_obj(@match).inspect}")
        print Byebug.printer.print_instance_variables(get_obj(@match))
      else
        var_instance_without_xml(*args)
      end
    end

    alias_method :var_instance_without_xml, :var_instance
    alias_method :var_instance, :var_instance_with_xml

    # reference inspection results in order to save them from the GC
    @@references = []
    def self.reference_result(result)
      @@references << result
    end
    def self.clear_references
      @@references = []
    end

    private

    def get_obj(match)
      if match[2]
        begin
          DebuggerXml.logger.puts("Getting object space: #{match[2].hex}")
          ObjectSpace._id2ref(match[2].hex)
        rescue RangeError
          errmsg "Unknown object id : %s" % match[2]
          nil
        end
      else
        bb_warning_eval(match.post_match.empty? ? 'self' : match.post_match)
      end
    end

    def var_inspect(obj_ref)
      obj = bb_eval(obj_ref)
      VarCommand.reference_result(obj)
      print prv({eval_result: obj}, 'local')
    end
  end

end
