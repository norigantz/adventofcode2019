$input = File.read('input').split(' ')[0].to_s
$base = [0, 1, 0, -1]

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

def FFT(signal)
	result = []
	signal = signal.split('').map(&:to_i)
	for i in 0..signal.length-1
		j = 0
		base_index = i > 0 ? 0 : 1
		sum = 0
		count = 1
		while j < signal.length
			sum += $base[base_index%4]*signal[j]
			j += 1
			if count >= i
				base_index += 1
				count = 0
			else
				count += 1
			end
		end
		result.push(digit(1,sum.abs))
	end
	s = ''
	for r in result
		s += r.to_s
	end
	s
end

r = FFT($input)
for i in 0..98
	r = FFT(r)
end
p r