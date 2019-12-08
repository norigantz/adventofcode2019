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
for l in layers
	currZeros = 0
	currOnes = 0
	currTwos = 0
	for pixel in l
		puts pixel
		for i in 0..25
			case digit(i+1, pixel)
			when 0
				currZeros += 1
			when 1
				currOnes += 1
			when 2
				currTwos += 1
			end
		end
	end
	if currZeros < digits_0
		digits_0 = currZeros
		bestLayer = l
		answer = currOnes * currTwos
	end
end
puts answer

