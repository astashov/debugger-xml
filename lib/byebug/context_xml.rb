module Byebug
  class Context
    class << self
      IGNORED_XML_FILES = Dir.glob(File.expand_path('../../../**/*.rb', __FILE__))

      def ignored_with_xml(path)
        ignored_without_xml(path) || IGNORED_XML_FILES.include?(path)
      end

      alias_method :ignored_without_xml, :ignored
      alias_method :ignored, :ignored_with_xml
    end
  end
end
