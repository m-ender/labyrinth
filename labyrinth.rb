# coding: utf-8

require_relative 'point2d'
require_relative 'direction'

class Labyrinth

    class ProgramError < Exception; end

    OPERATORS = {
        #' '  => ,
        '!'  => [:output_int],
        #'"'  => ,
        '#'  => [:nop],
        '$'  => [:depth],
        '%'  => [:mod],
        #'&'  => ,
        #'\'' => ,
        '('  => [:dec],
        ')'  => [:inc],
        '*'  => [:mul],
        '+'  => [:add],
        ','  => [:input_char],
        '-'  => [:sub],
        '.'  => [:output_char],
        '/'  => [:div],
        '0'  => [:digit, 0],
        '1'  => [:digit, 1],
        '2'  => [:digit, 2],
        '3'  => [:digit, 3],
        '4'  => [:digit, 4],
        '5'  => [:digit, 5],
        '6'  => [:digit, 6],
        '7'  => [:digit, 7],
        '8'  => [:digit, 8],
        '9'  => [:digit, 9],
        ':'  => [:dup],
        ';'  => [:pop],
        '<'  => [:rotate_west],
        '='  => [:swap_tops],
        '>'  => [:rotate_east],
        '?'  => [:input_int],
        '@'  => [:terminate],
        #'A'  => ,
        #'B'  => ,
        #'C'  => ,
        #'D'  => ,
        #'E'  => ,
        #'F'  => ,
        #'G'  => ,
        #'H'  => ,
        #'I'  => ,
        #'J'  => ,
        #'K'  => ,
        #'L'  => ,
        #'M'  => ,
        #'N'  => ,
        #'O'  => ,
        #'P'  => ,
        #'Q'  => ,
        #'R'  => ,
        #'S'  => ,
        #'T'  => ,
        #'U'  => ,
        #'V'  => ,
        #'W'  => ,
        #'X'  => ,
        #'Y'  => ,
        #'Z'  => ,
        #'['  => ,
        #'\\'  => ,
        #']'  => ,
        '^'  => [:rotate_north],
        '_'  => [:push_zero],
        #'`'  => ,
        #'a'  => ,
        #'b'  => ,
        #'c'  => ,
        #'d'  => ,
        #'e'  => ,
        #'f'  => ,
        #'g'  => ,
        #'h'  => ,
        #'i'  => ,
        #'j'  => ,
        #'k'  => ,
        #'l'  => ,
        #'m'  => ,
        #'n'  => ,
        #'o'  => ,
        #'p'  => ,
        #'q'  => ,
        #'r'  => ,
        #'s'  => ,
        #'t'  => ,
        #'u'  => ,
        'v'  => [:rotate_south],
        #'w'  => ,
        #'x'  => ,
        #'y'  => ,
        #'z'  => ,
        '{'  => [:move_to_main],
        #'|'  => ,
        '}'  => [:move_to_aux],
        #'~'  => ,
    }

    OPERATORS.default = [:wall]

    def self.run(src, debug_flag)
        new(src).run
    end

    def initialize(src)
        @grid = parse(src)
        @ip = find_start
        @dir = East.new
    end

    def run
        loop do
            cmd = cell @ip
            process cmd
            @dir = get_new_dir
            @ip += @dir.vec
        end
    end

    private

    def parse(src)
        lines = src.split($/)

        grid = lines.map{|l| l.chars.map{|c| OPERATORS[c]}}

        width = grid.map(&:size).max

        grid.each{|l| l.fill([:wall], l.length...width)}
    end

    def find_start
        start = []
        @grid.each_with_index do |l,y|
            l.each_with_index do |c,x|
                if c[0] != :wall
                    start = Point2D.new(x,y)
                    break
                end
            end
            if start != []
                break
            end
        end

        start
    end

    def x
        @ip.x
    end

    def y
        @ip.y
    end

    def cell coords
        line = @grid[coords.y] || []
        line[coords.x] || [:wall]
    end

    def process cmd
        p cmd
    end

    def get_new_dir
        @dir
    end
end

debug_flag = ARGV[0] == "-d"
if debug_flag
    ARGV.shift
end

Labyrinth.run(ARGF.read, debug_flag)