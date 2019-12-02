input = File.read('input').split(',').map(&:to_i)
input[1] = 12
input[2] = 2
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
puts input[0]