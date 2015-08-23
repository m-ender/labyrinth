class Point2D
    attr_accessor :x, :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def self.from_string(string)
        coords = string.split.map(&:to_i)
        Point2D.new(coords[0], coords[1])
    end

    def +(other)
        if other.is_a?(Point2D)
            return Point2D.new(@x+other.x, @y+other.y)
        end
    end

    def coerce(other)
        return self, other
    end

    def to_s
        "#{@x} #{@y}"
    end

    def pretty
        "(% d,% d)" % [@x, @y]
    end
end