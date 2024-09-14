#! /usr/bin/env ruby

require "json"

EMPTY = "\"[[EMPTY]]\""

def get()
  get_cmd = "hyprctl -j getoption decoration:screen_shader"
  io = IO.popen(get_cmd) 

  parsed = JSON.parse(io.gets)

  return parsed["str"]
end

def set(path)
  set_cmd = "hyprctl keyword decoration:screen_shader #{path}"
  io = IO.popen(set_cmd)

  return io.gets
end

def put_status (arg)
  puts "Status: #{arg}"
end

cmd = ARGV[0]
arg = ARGV.length < 2 ? EMPTY : ARGV[1]

if cmd == "get" then
  put_status(get())
elsif cmd == "set" then 
  put_status(set(arg))
elsif ARGV.length <= 0 then
  puts "     ---   hyprshift   ---",
    "get - Get screen_shader status.",
    "  hyprshift get",
    "set - Set screen_shader status.",
    "  hyprshift set [path:optional]",
    "  path: Path to the shader file."
end
