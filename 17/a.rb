$input = File.read('input').split(',').map(&:to_i)

class Robot
	attr_accessor :machine, :grid, :running, :x, :y, :minX, :maxX, :minY, :maxY, :alignment_sum

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
		@alignment_sum = 0
	end

	def set_cell(tile_id)
		if tile_id == 10
			@y += 1
			@x = 0
		else
			case tile_id
			when 35
				@grid[@y*100+@x] = '#'
			when 46
				@grid[@y*100+@x] = '.'
			end
			@x += 1
		end
		@minX = @x unless @minX <= @x
		@maxX = @x unless @maxX >= @x
		@minY = @y unless @minY <= @y
		@maxY = @y unless @maxY >= @y
	end

	def run
		@machine.set_signal(@joystick)
		out = @machine.run
		if out != nil and out.length == 1
			set_cell(out[0])
			@machine.signal_out = []
		elsif out == nil
			halt_machine
		end
	end

	def is_intersection(i, j)
		center = @grid[j*100+i] == '#'
		north = @grid[(j-1)*100+i] == '#'
		south = @grid[(j+1)*100+i] == '#'
		east = @grid[j*100+i+1] == '#'
		west = @grid[j*100+i-1] == '#'
		center and north and south and east and west
	end

	def draw_grid
		result = []
		for j in @minY..@maxY
			row = []
			for i in @minX..@maxX
				if @grid[j*100+i] == nil
					row.push('-')
				else
					if is_intersection(i, j)
						@alignment_sum += ((i-@minX) * (j-@minY)).abs
						row.push('O')
					else
						row.push(@grid[j*100+i])
					end
				end
			end
			result.push(row)
		end
		for row in result
			p row
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

r = Robot.new
while r.running
	r.run
end
r.draw_grid
p r.alignment_sum