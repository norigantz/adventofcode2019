$input = File.read('input').split(',').map(&:to_i)
$amp_out = [0,0,0,0,0]

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

def intcode(input, phase, ampInput, amp)
	inputInstance = 0
	i = 0
	while input[i] != 99
		if digit(1, input[i]) == 1
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			input[input[i+3]] = first + second
			i += 4
		elsif digit(1, input[i]) == 2
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			input[input[i+3]] = first * second
			i += 4
		elsif input[i] == 3
			param = inputInstance == 0 ? phase : ampInput
			inputInstance += 1
			input[input[i+1]] = param
			i += 2
		elsif digit(1, input[i]) == 4
			$amp_out[amp] = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			i += 2
		elsif digit(1, input[i]) == 5
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			if first != 0
				i = second
			else
				i += 3
			end
		elsif digit(1, input[i]) == 6
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			if first == 0
				i = second
			else
				i += 3
			end
		elsif digit(1, input[i]) == 7
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			if first < second
				input[input[i+3]] = 1
			else
				input[input[i+3]] = 0
			end
			i += 4
		elsif digit(1, input[i]) == 8
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			if first == second
				input[input[i+3]] = 1
			else
				input[input[i+3]] = 0
			end
			i += 4
		else
			puts 'bad case: ' + input[i].to_s + ' on amp ' + amp.to_s
			return nil
		end
	end
	return input
end

def amplifier(phase, ampInput, amp)
	code = $input[0..$input.length]
	signal = intcode(code, phase, ampInput, amp)
	if signal == nil
		puts 'phase: ' + phase.to_s
		puts 'ampInput: ' + ampInput.to_s
	end
end

def phase()
	maxOut = 0
	maxInputPhase = 0
	inputPhase = 1
	phaseSet = [0,0,0,0,0]
	while inputPhase <= 43210
		while !isValidPhase(inputPhase)
			inputPhase += 1
		end
		for i in 0..4
			phaseSet[i] = digit(5-i, inputPhase)
		end
		for i in 0..4
			ampIndex = i == 0 ? 0 : (i - 1)
			amplifier(phaseSet[i], $amp_out[ampIndex], i)
		end
		if $amp_out[4] > maxOut
			maxOut = $amp_out[4]
			maxInputPhase = inputPhase
		end
		$amp_out = [0,0,0,0,0]
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
			if curr > 4 || digit(j, num) > 4
				return false
			end
		end
	end
	return !cond_match
end

phase()