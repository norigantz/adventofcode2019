$input = File.read('input').split(',').map(&:to_i)

class Droid
	attr_accessor :machine, :grid, :instruction, :running, :x, :y, :minX, :maxX, :minY, :maxY, :goal_node
	MOVE = [NORTH=1, SOUTH=2, EAST=3, WEST=4]

	def initialize
		@machine = Machine.new('A', $input)
		@grid = Hash.new
		@running = true
		@x = 0
		@y = 0
		@minX = 0
		@maxX = 0
		@minY = 0
		@maxY = 0
		@grid[0] = 1
	end

	def select_direction
		@instruction = rand(4)+1
	end

	def move_grid(tile_id)
		if tile_id == 0
			case @instruction
			when NORTH
				@grid[(@y-1)*100+@x] = tile_id
				@minY = @y-1 unless @minY <= @y-1
			when SOUTH
				@grid[(@y+1)*100+@x] = tile_id
				@maxY = @y+1 unless @maxY >= @y+1
			when EAST
				@grid[@y*100+@x+1] = tile_id
				@maxX = @x+1 unless @maxX >= @x+1
			when WEST
				@grid[@y*100+@x-1] = tile_id
				@minX = @x-1 unless @minX <= @x-1
			end
		else
			case @instruction
			when NORTH
				@y -= 1
			when SOUTH
				@y += 1
			when EAST
				@x += 1
			when WEST
				@x -= 1
			end
			@grid[@y*100+@x] = tile_id
			@minX = @x unless @minX <= @x
			@maxX = @x unless @maxX >= @x
			@minY = @y unless @minY <= @y
			@maxY = @y unless @maxY >= @y
		end
	end

	def move_machine(dir)
		@instruction = dir
		@machine.set_signal(@instruction)
		out = []
		while out != nil and out.length != 1
			out = @machine.run
		end
		if out != nil and out.length == 1
			move_grid(out[0])
			@machine.signal_out = []
		elsif out == nil
			halt_machine
		end
		out[0]
	end

	def run
		moveStack = []
		discovered = 0
		loop do
			if grid[(@y-1)*100+@x] == nil or grid[(@y+1)*100+@x] == nil or grid[@y*100+@x+1] == nil or grid[@y*100+@x-1] == nil
				pos = -1
				choose = 0
				while pos == -1
					choose = rand(4) + 1
					case choose
					when 1
						pos = move_machine(NORTH) unless grid[(@y-1)*100+@x] != nil
					when 2
						pos = move_machine(SOUTH) unless grid[(@y+1)*100+@x] != nil
					when 3
						pos = move_machine(EAST) unless grid[@y*100+@x+1] != nil
					when 4
						pos = move_machine(WEST) unless grid[@y*100+@x-1] != nil
					end
				end
				if pos != 0
					moveStack.unshift(choose)
					discovered += 1
					if pos == 2
						@goal_node = @y*100+@x
					end
				end
			else
				unmove = moveStack.shift
				case unmove
				when NORTH
					move_machine(SOUTH)
				when SOUTH
					move_machine(NORTH)
				when EAST
					move_machine(WEST)
				when WEST
					move_machine(EAST)
				end
			end
			break if discovered > 5 and @x == 0 and @y == 0
		end
		draw_grid
	end

	def draw_grid
		result = []
		for j in @minY..@maxY
			row = []
			for i in @minX..@maxX
				if @grid[j*100+i] == nil
					row.push(3)
				else
					row.push(@grid[j*100+i])
				end
			end
			result.push(row)
		end
		# result = result.reverse
		for row in result
			p row.inspect
		end
	end

	def halt_machine
		@running = false
	end
end

class Machine
	attr_accessor :label, :machine_out, :intcode, :position, :signal_in, :signal_out, :yield, :halt, :base

	def initialize(label, intcode)
		@label = label
		@intcode = intcode
		for i in 0..1000
			@intcode.push(0)
		end
		@signal_in = []
		@signal_out = []
		@position = 0
		@yield = false
		@halt = false
		@base = 0
	end

	def init(intcode)
		initialize(@label, intcode)
	end

	def setOut(machine)
		@machine_out = machine
	end

	def run
		if !@yield and !@halt
			intcode
			return @signal_out
		end
		return nil
	end

	def push_signal(signal)
		@signal_in.push(signal)
		@yield = false
	end

	def set_signal(signal)
		@signal_in = [signal]
		@yield = false
	end

	def intcode
		if @intcode[@position] == 99
			@halt = true
			return
		end

		first = 0
		case digit(3, @intcode[@position])
		when 0
			first = @intcode[@intcode[@position+1]]
		when 1
			first = @intcode[@position+1]
		when 2
			first = @intcode[@intcode[@position+1]+@base]
		end
		if first == nil
			first = 0
		end

		second = 0
		case digit(4, @intcode[@position])
		when 0
			second = @intcode[@intcode[@position+2]]
		when 1
			second = @intcode[@position+2]
		when 2
			second = @intcode[@intcode[@position+2]+@base]
		end
		if second == nil
			second = 0
		end

		case digit(1, @intcode[@position])
		when 1
			position = digit(5, @intcode[@position]) == 2 ? @intcode[@position+3]+@base : @intcode[@position+3]
			@intcode[position] = first + second
			@position += 4
		when 2
			position = digit(5, @intcode[@position]) == 2 ? @intcode[@position+3]+@base : @intcode[@position+3]
			@intcode[position] = first * second
			@position += 4
		when 3
			if digit(3, @intcode[@position]) == 0
				@intcode[@intcode[@position+1]] = @signal_in.shift()
			elsif digit(3, @intcode[@position]) == 2
				@intcode[@intcode[@position+1]+@base] = @signal_in.shift()
			end
			@position += 2
		when 4
			case digit(3, @intcode[@position])
			when 0
				@signal_out.push(@intcode[@intcode[@position+1]])
			when 1
				@signal_out.push(@intcode[@position+1])
			when 2
				@signal_out.push(@intcode[@intcode[@position+1]+@base])
			end
			@position += 2
		when 5
			if first != 0
				@position = second
			else
				@position += 3
			end
		when 6
			if first == 0
				@position = second
			else
				@position += 3
			end
		when 7
			position = digit(5, @intcode[@position]) == 2 ? @intcode[@position+3]+@base : @intcode[@position+3]
			if first < second
				@intcode[position] = 1
			else
				@intcode[position] = 0
			end
			@position += 4
		when 8
			position = digit(5, @intcode[@position]) == 2 ? @intcode[@position+3]+@base : @intcode[@position+3]
			if first == second
				@intcode[position] = 1
			else
				@intcode[position] = 0
			end
			@position += 4
		when 9
			@base += first
			@position += 2
		else
			puts 'bad case: ' + @intcode[@position].to_s + ' on machine ' + @label.to_s
			return nil
		end
	end
end

def numdigits(num)
	count = 0
	n = num
	while n != 0
		n /= 10
		count += 1
	end
	return count
end

def digit(i, num)
	(num % (10**i))/10**(i-1) unless i <= 0
end

def get_neighbors(graph, x, y)
	result = []
	result.push((y-1)*100+x) unless graph[(y-1)*100+x] == 0
	result.push((y+1)*100+x) unless graph[(y+1)*100+x] == 0
	result.push(y*100+x-1) unless graph[y*100+x-1] == 0
	result.push(y*100+x+1) unless graph[y*100+x+1] == 0
	result
end

def minDist(dist, nodes)
	minNode = nodes.first
	for node in nodes
		if dist[node] < dist[minNode]
			minNode = node
		end
	end
	return minNode
end

$r = Droid.new
$r.run

def dijkstra
	dist = Hash.new
	queue = []
	for j in $r.minY..$r.maxY
		for i in $r.minX..$r.maxX
			if $r.grid[j*100+i] == 1 || $r.grid[j*100+i] == 2
				dist[j*100+i] = 999999
				queue.push(j*100+i)
			end
		end
	end
	dist[0] = 0
	while queue.any?
		v = minDist(dist, queue)
		queue.delete(v)
		x = v%100
		y = (v-x)/100
		neighbors = get_neighbors($r.grid, x, y)
		for neighbor in neighbors
			if neighbor == nil
				next
			end
			alt = dist[v] + 1
			if alt < dist[neighbor]
				dist[neighbor] = alt
			end
		end
	end
	return dist
end

dist = dijkstra
p dist[$r.goal_node]