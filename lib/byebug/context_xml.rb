module Byebug
  class Context
    class << self

      def stack_size(byebug_frames = false)
        backtrace = Thread.current.backtrace_locations(0)
        return 0 unless backtrace

        unless byebug_frames
          backtrace = backtrace.select { |l| !ignored_file?(l.path) }
        end
        backtrace.size
      end
    end

    IGNORED_XML_FILES = Dir.glob(File.expand_path('../../../**/*', __FILE__))

    def ignored_file_with_xml(path)
      result = ignored_file_without_xml(path) ||
        IGNORED_XML_FILES.include?(path) ||
        !!path.match(/^\(eval\)/) ||
        !!path.match(/rdebug-vim$/) ||
        !!path.match(/rdebug-ide$/)
      result
    end

    alias_method :ignored_file_without_xml, :ignored_file?
    alias_method :ignored_file?, :ignored_file_with_xml

  end
end
