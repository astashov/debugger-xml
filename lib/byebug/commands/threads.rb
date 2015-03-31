module Byebug
  module ThreadFunctions # :nodoc:
    def thread_arguments_with_pid(context, should_show_top_frame = true)
      thread_arguments_without_pid(context, should_show_top_frame)
          .merge(
              pid: Process.pid,
              status: context.thread.status,
              current: (context.thread == Thread.current),
          )
    end

    alias_method :thread_arguments_without_pid, :thread_arguments
    alias_method :thread_arguments, :thread_arguments_with_pid
  end
end
