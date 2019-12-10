$input = File.read('input').split(' ')
$counted = []

def GCF(a, b)
    a = a.abs()
	b = b.abs()
	while a != b
		if a > b
			a -= b
		else
			b -= a
		end
	end
	return a
end

def raycast(i, j, dx, dy)
	# puts 'start raycast from ' + i.to_s + ', ' + j.to_s + ' with delta ' + dx.to_s + ', ' + dy.to_s
	if dx == 0 and dy == 0
		return 0
	end

	if dx.abs() > 0 and dy.abs() > 0
		gcf = GCF(dx, dy)
		dx /= gcf
		dy /= gcf
	elsif dx == 0
		dy /= dy.abs()
	elsif dy == 0
		dx /= dx.abs()
	end
		
	# puts 'new delta: ' + dx.to_s + ', ' + dy.to_s

	deltaX = dx
	deltaY = dy
	iterations = 1
	while i+dx >= 0 and j+dy >= 0 and $input[j+dy] != nil and $input[j+dy][i+dx] != nil
		if $counted[(j+dy)*$input[0].length + (i+dx)]
			return 0
		end
		if $input[j+dy][i+dx] == '#'
			$counted[(j+dy)*$input[0].length + (i+dx)] = true
			# puts 'asteroid found at: '
			# puts i+dx
			# puts j+dy
			# puts ' '
			return 1
		else
			dx = iterations*deltaX
			dy = iterations*deltaY
			iterations += 1
		end
	end
	return 0
end

def perform_raycasts(i, j)
	curr = 0
	$counted = []
	for dy in -$input.length..$input.length
		for dx in -$input[0].length..$input[0].length
			curr += raycast(i, j, dx, dy)
		end
	end
	return curr
end

# char value 35 is asteroid
# char value 46 is empty space
max = 0
bestX = 0
bestY = 0
for j in 0..$input.length-1
	for i in 0..$input[0].length-1
		if $input[j][i] == '#'
			curr = perform_raycasts(i, j)
			if max < curr
				max = curr
				bestX = i
				bestY = j
			end
		end
	end
end

puts 'best location is ' + bestX.to_s + ',' + bestY.to_s + ' with visibility ' + max.to_s