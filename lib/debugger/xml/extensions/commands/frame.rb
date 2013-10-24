module Debugger
  module FrameFunctions

    # Mark should be 'true' or 'false', as a String
    def get_pr_arguments_with_xml(mark, *args)
      res = get_pr_arguments_without_xml((!!mark).to_s, *args)
      res[:file] = File.expand_path(res[:file])
      res
    end

    alias_method :get_pr_arguments_without_xml, :get_pr_arguments
    alias_method :get_pr_arguments, :get_pr_arguments_with_xml

  end
end

