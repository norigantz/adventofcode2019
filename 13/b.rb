$input = File.read('input').split(',').map(&:to_i)
$input[0] = 2 # Free Play mode

class Game
	attr_accessor :machine, :x, :y, :grid, :running, :minX, :minY, :maxX, :maxY, :block_count, :joystick, :score, :ballX, :paddleX
	STICK = [LEFT=-1, NEUTRAL=0, RIGHT=1]

	def initialize
		@machine = Machine.new('A', $input)
		@x = 0
		@y = 0
		@minX = 0
		@minY = 0
		@maxX = 0
		@maxY = 0
		@grid = Hash.new
		@running = true
		@block_count = 0
		@joystick = 0
		@score = 0
		@ballX = 0
		@paddleX = 0
	end

	def auto_pilot
		if @paddleX > @ballX
			set_stick(LEFT)
		elsif @paddleX < @ballX
			set_stick(RIGHT)
		elsif @paddleX == @ballX
			set_stick(NEUTRAL)
		end
	end

	def set_stick(dir)
		@joystick = dir
	end

	def set_cell(x, y, tile_id)
		if x == -1 and y == 0
			@score = tile_id
			return
		end
		@grid[y*100+x] = tile_id
		if x < @minX
			@minX = x
		elsif x > @maxX
			@maxX = x
		end
		if y < @minY
			@minY = y
		elsif y > @maxY
			@maxY = y
		end

		if tile_id == 2
			@block_count += 1
		elsif tile_id == 3
			@paddleX = x
		elsif tile_id == 4
			@ballX = x
		elsif @grid[y*100+x] == 2
			@block_count -= 1
		end
	end

	def run
		@machine.set_signal(@joystick)
		out = @machine.run
		if out != nil and out.length == 3
			set_cell(out[0], out[1], out[2])
			@machine.signal_out = []
		elsif out == nil
			halt_machine
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
	(num % (10**i))/10**(i-1) unless i <= 0 or i > 6
end

r = Game.new
while r.running
	r.run
	r.auto_pilot
end

puts r.score

# grid = r.grid
# result = []
# for y in r.minY..r.maxY
# 	row = []
# 	for x in r.minX..r.maxX
# 		if grid[y*100+x] == nil
# 			row.push(0)
# 		else
# 			row.push(grid[y*100+x])
# 		end
# 	end
# 	result.push(row)
# end
# result = result.reverse
# for row in result
# 	puts row.inspect
# end