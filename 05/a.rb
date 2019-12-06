$input = File.read('input').split(',').map(&:to_i)

def numdigits(num)
		count = 0
		n = num
		while n != 0
			n /= 10
			count += 1
		end
		count
end

def digit(i, num)
	(num % (10**i))/10**(i-1) unless i <= 0 or i > 6
end

def intcode(input, param)
	i = 0
	while 1
		if digit(1, input[i]) == 1
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			input[input[i+3]] = first + second
			i += 4
		elsif digit(1, input[i]) == 2
			irst = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			input[input[i+3]] = first * second
			i += 4
		elsif input[i] == 3
			input[input[i+1]] = param
			i += 2
		elsif input[i] == 4
			puts input[input[i+1]]
			i += 2
		elsif input[i] == 99
			break
		end
	end
	return input[0]
end

def tryintcode(a, b)
	code = $input[0..$input.length]
	code[1] = a
	code[2] = b
	return intcode(code)
end

intcode($input, 1)