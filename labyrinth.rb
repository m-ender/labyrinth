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

        @main = []
        @aux = []
    end

    def run
        loop do
            cmd = cell @ip
            if cmd[0] == :terminate
                break
            end
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

    def push_main val
        @main << val
    end

    def push_aux val
        @aux << val
    end

    def pop_main
        @main.pop || 0
    end

    def pop_aux
        @aux.pop || 0
    end

    def peek_main
        @main[-1] || 0
    end

    def process cmd
        opcode, param = *cmd

        case opcode
        # Arithmetic
        when :push_zero
            push_main 0
        when :digit
            push_main(pop_main*10 + param)
        when :inc
            push_main(pop_main+1)
        when :dec
            push_main(pop_main-1)
        when :add
            push_main(pop_main+pop_main)
        when :sub
            a = pop_main
            b = pop_main
            push_main(b-a)
        when :mul
            push_main(pop_main*pop_main)
        when :div
            a = pop_main
            b = pop_main
            push_main(b/a)
        when :mod
            a = pop_main
            b = pop_main
            push_main(b%a)

        # Stack manipulation
        when :dup
            push_main(peek_main)
        when :pop
            pop_main
        when :move_to_main
            push_main(pop_aux)
        when :move_to_aux
            push_aux(pop_main)
        when :swap_tops
            a = pop_aux
            m = pop_main
            push_aux m
            push_main a
        when :depth
            push_main(@main.size)

        # I/O
        when :input_char
            push_main(read_byte.ord)
        when :output_char
            $> << pop_main.chr
        when :input_int
            val = 0
            sign = 1
            byte = read_byte
            case byte
            when '+'.ord
                sign = 1
            when '-'.ord
                sign = -1
            else
                @next_byte = byte
            end

            loop do
                byte = read_byte.chr
                if byte[/\d/]
                    val = val*10 + byte.to_i
                else
                    @next_byte = byte
                    break
                end
            end

            push_main(sign*val)
        when :output_int
            $> << pop_main

        # Grid manipulation
        when :rotate_west
            @grid[y+pop_main].rotate!(1)
        when :rotate_east
            @grid[y+pop_main].rotate!(-1)
        when :rotate_north
            grid = @grid.transpose
            grid[x+pop_main].rotate!(1)
            @grid = grid.transpose
        when :rotate_south
            grid = @grid.transpose
            grid[x+pop_main].rotate!(-1)
            @grid = grid.transpose

        # Others
        when :terminate
            raise '[BUG] Received :terminate. This shouldn\'t happen.'
        when :nop
            # Nop(e)
        end
    end

    def get_new_dir
        neighbors = []
        [North.new,
         East.new,
         South.new,
         West.new].each do |dir|
            neighbors << dir if cell(@ip + dir.vec)[0] != :wall
        end
        case neighbors.size
        when 0
            # Remain where you are by moving back one step.
            # This can only happen at the start or due to shifting.
            @ip += @dir.reverse
            @dir
        when 1
            # Move in the only possible direction
            neighbors[0]
        when 2
            neighbors = neighbors.select {|d| d.reverse != @dir}
            # If we came from one of the two directions, pick the other.
            # Otherwise, keep moving straight ahead (this can only happen
            # at the start or due to shifting).
            if neighbors.size == 2
                @dir
            else
                neighbors[0]
            end
        when 3
            val = peek_main
            if val < 0
                dir = @dir.left
            elsif val == 0
                dir = @dir
            else
                dir = @dir.right
            end
            if !neighbors.include? dir
                dir = dir.reverse
            end
            dir
        when 4
            val = peek_main
            if val < 0
                @dir.left
            elsif val == 0
                @dir
            else
                @dir.right
            end
        end
    end

    def read_byte
        result = nil
        if @next_byte
            result = @next_byte
            @next_byte = nil
        else
            result = STDIN.read(1)
        end
        result
    end
end

debug_flag = ARGV[0] == "-d"
if debug_flag
    ARGV.shift
end

Labyrinth.run(ARGF.read, debug_flag)