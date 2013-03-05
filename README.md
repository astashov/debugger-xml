## Description

This is a gem, which adds the XML printer to the 'debugger' gem, using the same API as
the ruby-debug-ide gem, which allows it to be used with Ruby IDEs (for example, in my
vim-ruby-debugger :))

## Installation

As usual, add it to your Gemfile, and you are all set

    gem 'debugger-xml'

## Usage

There is the the bin/rdebug-ide file, check it out. For description of XML API,
check http://debug-commons.rubyforge.org/protocol-spec.html, I tried to be
compatible with it

## Tests

It uses debugger/test helpers. To run all tests, just do

    rake test

