## 0.1.0
* Added rdebug-vim, used by vim-ruby-debugger. It is designed specifically for that vim plugin.
  It creates new unix socket, and listen connections to it. After receiving commands/events, it
  writes response to a file, and pokes Vim, so it can read it.

## 0.0.4
* First working version, copies ruby-debug-ide interface
