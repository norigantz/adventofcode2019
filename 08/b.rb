$input = File.read('input').to_i

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

def form_value(arr)
	numdigits = arr.length
	value = 0
	for i in arr
		value += (10**numdigits)*i
		numdigits -= 1
	end
	return value
end

def process_image(width, height)
	layers = []
	pixels = []
	currVal = []
	inputLength = numdigits($input)
	for d in 0..inputLength
		currVal.push(digit(1+inputLength-d, $input))
		if currVal.length == width
			pixels.push(form_value(currVal))
			currVal = []
		end
		if pixels.length == height
			layer = pixels[0..pixels.length]
			layers.push(layer)
			pixels = []
		end
	end
	return layers
end

layers = process_image(25, 6)
digits_0 = 999999
bestLayer = nil
answer = 0
result = []
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
result.push([2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2])
for l in layers
	currZeros = 0
	currOnes = 0
	currTwos = 0
	for row in 0..5
		for i in 0..25
			if result[row][i] == 2 and digit(26-i, l[row]) != 2
				result[row][i] = digit(26-i, l[row])
			end
		end
	end
	if currZeros < digits_0
		digits_0 = currZeros
		bestLayer = l
		answer = currOnes * currTwos
	end
end

for r in result
	puts r.inspect
end