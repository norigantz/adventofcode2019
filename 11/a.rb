$input = File.read('input').split(',').map(&:to_i)

class Robot
	attr_accessor :machine, :facing, :x, :y, :grid, :paint_count, :running
	FACE = [UP=0, RIGHT=1, DOWN=2, LEFT=3]

	def initialize
		@machine = Machine.new('A', $input)
		@facing = UP
		@x = 0
		@y = 0
		@grid = Hash.new
		@paint_count = 0
		@running = true
	end

	def paint(col)
		if @grid[@x*100+@y] == nil
			@paint_count += 1
		end
		@grid[@x*100+@y] = col
	end

	def turn(dir)
		puts 'pos: ' + @x.to_s + ', ' + @y.to_s
		@facing = dir == 0 ? (@facing-1)%4 : (@facing+1)%4
		step
	end

	def step()
		case @facing
		when 0
			@y += 1
		when 1
			@x += 1
		when 2
			@y -= 1
		when 3
			@x -= 1
		end
	end

	def run
		# if @machine.signal_in.length == 0
		@machine.set_signal(@grid[@x*100+@y] == 1 ? 1 : 0)
			# puts @machine.signal_in.inspect
		# end
		out = @machine.run
		if out != nil and out.length == 2
			paint(out[0])
			turn(out[1])
			@machine.signal_out = []
		elsif out == nil
			halt_machine
		end
	end

	def halt_machine
		@running = false
		puts @paint_count
	end
end

class Machine
	attr_accessor :label, :machine_out, :intcode, :position, :signal_in, :signal_out, :yield, :halt, :base

	def initialize(label, intcode)
		@label = label
		@intcode = intcode
		# for i in 0..1000
			# @intcode.push(0)
		# end
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
			# puts @signal_out.inspect
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
			puts 'halt'
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

r = Robot.new
while r.running
	r.run
end