require_relative 'point2d'

class North
    def right() East.new end
    def left() West.new end
    def reverse() South.new end
    def vec() Point2D.new(0,-1) end

    def ==(other) other.is_a?(North) end
    def coerce(other) return self, other end
end

class East
    def right() South.new end
    def left() North.new end
    def reverse() West.new end
    def vec() Point2D.new(1,0) end

    def ==(other) other.is_a?(East) end
    def coerce(other) return self, other end
end

class South
    def right() West.new end
    def left() East.new end
    def reverse() North.new end
    def vec() Point2D.new(0,1) end

    def ==(other) other.is_a?(South) end
    def coerce(other) return self, other end
end

class West
    def right() North.new end
    def left() South.new end
    def reverse() East.new end
    def vec() Point2D.new(-1,0) end

    def ==(other) other.is_a?(West) end
    def coerce(other) return self, other end
end