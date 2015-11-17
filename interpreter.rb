# coding: utf-8

require_relative 'labyrinth'

case ARGV[0]
when "-d"
    debug_level = 1
when "-D"
    debug_level = 2
else
    debug_level = 0
end

if debug_level > 0
    ARGV.shift
end

Labyrinth.run(ARGF.read, debug_level)