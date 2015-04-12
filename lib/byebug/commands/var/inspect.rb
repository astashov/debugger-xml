module Byebug
  class VarCommand < Command
    class InspectCommand < Command
      include Helpers::VarHelper

      # reference inspection results in order to save them from the GC
      @@references = []
      def self.reference_result(result)
        @@references << result
      end
      def self.clear_references
        @@references = []
      end

      def regexp
        /^\s* inspect (?:\s+ (.+))?\s*$/x
      end

      def execute
        var_inspect(@match[1])
      end

      def var_inspect(obj_ref)
        obj = bb_eval(obj_ref)
        VarCommand::InspectCommand.reference_result(obj)
        print prv({eval_result: obj}, 'local')
      end

      def short_description
        'Inspects a given object (supposed to be used only from ide).'
      end

      def description
        <<-EOD
          v[ar] inspect [object ref/expression]

          #{short_description}
        EOD
      end
    end
  end
end
