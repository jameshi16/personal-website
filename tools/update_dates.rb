#!/usr/bin/ruby
# Update the dates in a blog post

require 'time'
require 'pathname'
require_relative './common/handlers/time_updater_handler'

def help
  puts "Usage"
  puts "#{$0} <path to blog post>"
  puts "Changes the date of the blog post"
end

def command(time, arguments) # function to make things testable
  if arguments.empty?
    puts("need a path to a file")
    help
    return false
  end

  if arguments.length > 1
    puts("too many arguments")
    help
    return false
  end

  if not File.exist? arguments[0]
    puts("file with path: #{arguments[0]} doesn't exist")
    return false
  end

  handler = TimeUpdaterHandler.new(arguments[0], time, Pathname.pwd())
  handler.handle
  return true
end

if __FILE__ == $0
  exit command(Time.now, $*)
end
