$input = File.read('input').split(',').map(&:to_i)
seed = ARGV.map(&:to_i)
$target = 19690720
if seed.length == 2
	input[1] = seed[0]
	input[2] = seed[1]
end

def intcode(input)
	i = 0
	while 1
		if input[i] == 1
			input[input[i+3]] = input[input[i+1]] + input[input[i+2]]
		elsif input[i] == 2
			input[input[i+3]] = input[input[i+1]] * input[input[i+2]]
		elsif input[i] == 99
			break
		end
		i += 4
	end
	return input[0]
end

def tryintcode(a, b)
	code = $input[0..$input.length]
	code[1] = a
	code[2] = b
	return intcode(code)
end

for i in 0..100
	res = tryintcode(i, 0)
	if (res - $target).abs() < 10000
		if tryintcode(i, (res - $target).abs()) == $target
			puts i.to_s + (res-$target).abs().to_s
		end
	end
end