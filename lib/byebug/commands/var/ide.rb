module Byebug
  class VarCommand < Command
    class IdeCommand < Command
      include Helpers::VarHelper

      def regexp
        /^\s* ide \s*$/x
      end

      def execute
        var_ide
      end

      def short_description
        'Shows set of variables for IDE usage'
      end

      def description
        <<-EOD
          v[ar] ide

          #{short_description}
        EOD
      end
    end
  end
end
