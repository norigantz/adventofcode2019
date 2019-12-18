$input = File.read('input').split(' ')[0].to_s

def FFT(signal, offset)
	signal = signal.split('').map(&:to_i)
	length = signal.length-1
	for i in 0..99
		partial_sum = signal.inject(:+)
		for j in 0..length
			t = partial_sum
			partial_sum -= signal[j]
			if t >= 0
				signal[j] = (t%10)
			else
				signal[j] = (-t%10)
			end
		end
	end
	signal.map(&:to_s)
end

test_input = $input
test_input = test_input*10000
offset = test_input[0..6].to_i
test_input = test_input[offset..test_input.length]

r = FFT(test_input, offset)
p r[0..7]