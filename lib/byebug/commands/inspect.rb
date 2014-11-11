module Byebug
  class InspectCommand < Command
    # reference inspection results in order to save them from the GC
    @@references = []
    def self.reference_result(result)
      @@references << result
    end
    def self.clear_references
      @@references = []
    end

    def regexp
      /^\s*v(?:ar)?\s+inspect\s+/
    end

    def execute
      run_with_binding do |binding|
        obj = debug_eval(@match.post_match, binding)
        InspectCommand.reference_result(obj)
        print prv({eval_result: obj}, "local")
      end
    end

    def help
      %{
        v[ar] instpect <object>\tinpect a given object (supposed to be used only from ide)
      }
    end
  end
end
