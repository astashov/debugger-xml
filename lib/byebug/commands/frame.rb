module Byebug
  module FrameFunctions

    def get_pr_arguments_with_xml(frame_no)
      res = get_pr_arguments_without_xml(frame_no)
      res[:file] = File.expand_path(res[:file])
      res[:pos] = res[:pos].strip
      res
    end

    alias_method :get_pr_arguments_without_xml, :get_pr_arguments
    alias_method :get_pr_arguments, :get_pr_arguments_with_xml

  end
end
