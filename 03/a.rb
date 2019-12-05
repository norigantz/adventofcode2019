class Path
	attr_reader :edges

	def initialize(path)
		@edges = []
		addEdges(path)
	end

	def addEdge(start, delta)
		dir = delta[0]
		mag = delta[1..delta.length].to_i
		orientation = '' #can be hori or vert
		case dir
		when 'R'
			disp = Vector.new(mag, 0)
			orientation = 'hori'
		when 'L'
			disp = Vector.new(-mag, 0)
			orientation = 'hori'
		when 'U'
			disp = Vector.new(0, mag)
			orientation = 'vert'
		when 'D'
			disp = Vector.new(0, -mag)
			orientation = 'vert'
		end
		@edges.push(Edge.new(start, start+disp, orientation))
		return start+disp
	end

	def addEdges(dispList)
		start = Vector.new(0, 0)
		for disp in dispList
			start = addEdge(start, disp)
		end
	end
end

class Edge
	attr_reader :a, :b, :orientation

	def initialize(a, b, orientation)
		@a = a
		@b = b
		@orientation = orientation
	end

	def simpleintersect(e)
		if orientation == 'hori' and e.orientation == 'vert'
			if minX < e.a.x and maxX > e.a.x and a.y < e.maxY and a.y > e.minY
				Vector.new(e.a.x, a.y)
			end
		elsif orientation == 'vert' and e.orientation == 'hori'
			if a.x > e.minX and a.x < e.maxX and minY < e.a.y and maxY > e.a.y
				Vector.new(a.x, e.a.y)
			end
		end
	end

	def minX
		a.x < b.x ? a.x : b.x
	end

	def maxX
		a.x > b.x ? a.x : b.x
	end

	def minY
		a.y < b.y ? a.y : b.y
	end

	def maxY
		a.y > b.y ? a.y : b.y
	end

	def to_s
		"(" + @a.to_s + ")" + ", " + "(" + @b.to_s + ")"
	end
end

class Vector
	attr_reader :x, :y

	def initialize(x, y)
		@x = x
		@y = y
	end

	# The minimum zerodist intersect of Path1 and Path2 is the target answer
	def manhattan
		@x.abs() + @y.abs()
	end

	def +(v)
		Vector.new(@x+v.x, @y+v.y)
	end

	def to_s
		@x.to_s + ", " + @y.to_s
	end

end

input = File.read('input').split(' ')
line1 = input[0].split(',')
line2 = input[1].split(',')
path1 = Path.new(line1)
path2 = Path.new(line2)

intersects = []
for e1 in path1.edges
	for e2 in path2.edges
		intersect = e1.simpleintersect(e2)
		if intersect != nil
			intersects.push(intersect)
		end
	end
end

minIndex = 0
for i in 0..intersects.length-1
	if intersects[i].manhattan() < intersects[minIndex].manhattan()
		minIndex = i
	end
end

puts intersects[minIndex].manhattan()