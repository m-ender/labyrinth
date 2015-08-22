# coding: utf-8

#require_relative 'bit'

class Labyrinth

    class ProgramError < Exception; end

    OPERATORS = {
        ' '  => [:nop],
        '!'  => [:output_int],
        #'"'  => ,
        #'#'  => ,
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
    end

    def run
        @grid.each{|l| p l}
        p @ip
        while pc < @insns.size
            insn = @insns[pc]

            if insn == :debug
                puts
                puts @tree
            else
                command, bit = *@tree.process(insn)

                if bit
                    byte = @bits[bit, 8].map(&:state).join.to_i(2)
                end

                case command
                when :write
                    STDOUT << byte.chr
                when :read
                    byte = STDIN.read(1).ord
                    8.times { |i| 
                        @bits[bit + i].state = (byte>>(7-i))&1
                    }
                when :skip
                    pc += @bits[bit].state
                when :jump
                    pc = [pc + jump, 0].max
                end
            end

            pc += 1
        end
    end

    private

    def parse(src)
        lines = src.split($/)

        width = lines.map(&:size).max

        lines.map!{|l| l.ljust(width, '#')}

        lines.map{|l| l.chars.map{|c| OPERATORS[c]}}
    end

    def find_start
        start = []
        @grid.each_with_index do |l,y|
            l.each_with_index do |c,x|
                if c[0] != :wall
                    start = [x,y]
                    break
                end
            end
            if start != []
                break
            end
        end

        start
    end
end

debug_flag = ARGV[0] == "-d"
if debug_flag
    ARGV.shift
end

Labyrinth.run(ARGF.read, debug_flag)