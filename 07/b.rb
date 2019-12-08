$input = File.read('input').split(',').map(&:to_i)

class Amplifier
	attr_accessor :amp, :amp_out, :intcode, :position, :signal_in, :signal_out, :yield, :halt

	def initialize(amp, intcode)
		@amp = amp
		@intcode = intcode
		@signal_in = []
		@signal_out = 0
		@position = 0
		@yield = false
		@halt = false
	end

	def init(intcode)
		initialize(@amp, intcode)
	end

	def setOut(amp)
		@amp_out = amp
	end

	def run
		if !@yield and !@halt
			intcode()
		end
	end

	def push_signal(signal)
		@signal_in.push(signal)
		@yield = false
	end

	def intcode()
		if @intcode[@position] == 99
			@halt = true
			return
		end
		first = digit(3, @intcode[@position]) == 0 ? @intcode[@intcode[@position+1]] : @intcode[@position+1]
		second = digit(4, @intcode[@position]) == 0 ? @intcode[@intcode[@position+2]] : @intcode[@position+2]
		case digit(1, @intcode[@position])
		when 1
			@intcode[@intcode[@position+3]] = first + second
			@position += 4
		when 2
			@intcode[@intcode[@position+3]] = first * second
			@position += 4
		when 3
			if @signal_in.empty?
				@yield = true
				return
			end
			@intcode[@intcode[@position+1]] = @signal_in.shift()
			@position += 2
		when 4
			@signal_out = digit(3, @intcode[@position]) == 0 ? @intcode[@intcode[@position+1]] : @intcode[@position+1]
			@amp_out.push_signal(@signal_out)
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
			if first < second
				@intcode[@intcode[@position+3]] = 1
			else
				@intcode[@intcode[@position+3]] = 0
			end
			@position += 4
		when 8
			if first == second
				@intcode[@intcode[@position+3]] = 1
			else
				@intcode[@intcode[@position+3]] = 0
			end
			@position += 4
		else
			puts 'bad case: ' + @intcode[@position].to_s + ' on amp ' + @amp.to_s
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

def phase()
	maxOut = 0
	maxInputPhase = 0
	inputPhase = 55555
	phaseSet = [0,0,0,0,0]
	while inputPhase <= 98765
		while !isValidPhase(inputPhase)
			inputPhase += 1
		end
		for i in 0..4
			phaseSet[i] = digit(5-i, inputPhase)
		end
		@ampA.init($input[0..$input.length])
		@ampB.init($input[0..$input.length])
		@ampC.init($input[0..$input.length])
		@ampD.init($input[0..$input.length])
		@ampE.init($input[0..$input.length])
		@ampA.push_signal(phaseSet[0])
		@ampB.push_signal(phaseSet[1])
		@ampC.push_signal(phaseSet[2])
		@ampD.push_signal(phaseSet[3])
		@ampE.push_signal(phaseSet[4])
		@ampA.push_signal(0)
		while !@ampE.halt
			@ampA.run()
			@ampB.run()
			@ampC.run()
			@ampD.run()
			@ampE.run()
		end
		if @ampE.signal_out > maxOut
			maxOut = @ampE.signal_out
			maxInputPhase = inputPhase
		end
		inputPhase += 1
	end
	puts 'maxOut: ' + maxOut.to_s + ', inputPhase: ' + maxInputPhase.to_s
end

def isValidPhase(num)
	cond_match = false
	cond_val = true
	for i in 1..numdigits(num)
		curr = digit(i, num)
		for j in 1..numdigits(num)
			if j == i
				next
			end
			if curr == digit(j, num)
				cond_match = true
			end
			if curr < 5 || digit(j, num) < 5
				return false
			end
		end
	end
	return !cond_match
end

@ampA = Amplifier.new('A', $input[0..$input.length])
@ampB = Amplifier.new('B', $input[0..$input.length])
@ampC = Amplifier.new('C', $input[0..$input.length])
@ampD = Amplifier.new('D', $input[0..$input.length])
@ampE = Amplifier.new('E', $input[0..$input.length])
@ampA.setOut(@ampB)
@ampB.setOut(@ampC)
@ampC.setOut(@ampD)
@ampD.setOut(@ampE)
@ampE.setOut(@ampA)
phase()