module Byebug
  module Helpers
    module VarHelper # :nodoc:
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

      def var_ide(*_)
        locals = []
        _self = @state.context.frame_self(@state.frame)
        locals << ['self', _self] unless _self.to_s == "main"
        locals += @state.context.frame_locals(@state.frame).sort.map { |key, value| [key, value] }
        print prv(locals, 'instance')
      end

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
    end
  end
end
