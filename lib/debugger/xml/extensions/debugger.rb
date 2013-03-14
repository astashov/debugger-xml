module Debugger
  class << self
    attr_accessor :wait_for_start

    def start_remote_ide(host, port)
      return if @control_thread
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      start
      @control_thread = DebugThread.new do
        server = TCPServer.new(host, port)
        while (session = server.accept)
          interface = Xml::IdeInterface.new(session)
          processor = Xml::IdeControlCommandProcessor.new(interface)
          self.handler = Xml::IdeProcessor.new(interface)
          processor.process_commands
        end
      end
      @mutex.synchronize { @proceed.wait(@mutex) } if wait_for_start
    end

    def proceed
      return unless @mutex
      @mutex.synchronize { @proceed.signal }
    end

  end
end
