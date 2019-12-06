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
			first = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			second = digit(4, input[i]) == 0 ? input[input[i+2]] : input[i+2]
			input[input[i+3]] = first * second
			i += 4
		elsif input[i] == 3
			input[input[i+1]] = param
			i += 2
		elsif digit(1, input[i]) == 4
			output = digit(3, input[i]) == 0 ? input[input[i+1]] : input[i+1]
			puts output
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
		elsif input[i] == 99
			break
		else
			puts 'bad case: ' + input[i].to_s
			break
		end
	end
	return input[0]
end

intcode($input, 5)