$input = File.read('input').split(' ')
$counted = []
$angle = Hash.new()
$keys = []
$destroyed = []
$curr_visible = []
$total_angles = 0

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

def add_angle(i, j, i2, j2)
	dx = i2 - i
	dy = j2 - j
	if dx != 0 and dy != 0
		gcf = GCF(dx, dy)
		dx /= gcf
		dy /= gcf
	elsif dx == 0
		dy /= dy.abs()
	elsif dy == 0
		dx /= dx.abs()
	end

	a = Math.atan2(dx, dy)
	if $angle[a] == nil
		$angle[a] = []
		$keys.push(a)
	end
	$angle[a].push(i2*100+j2)
	$total_angles += 1
end

def raycast(i, j, dx, dy)
	if dx == 0 and dy == 0
		return 0
	end

	if dx != 0 and dy != 0
		gcf = GCF(dx, dy)
		dx /= gcf
		dy /= gcf
	elsif dx == 0
		dy /= dy.abs()
	elsif dy == 0
		dx /= dx.abs()
	end

	deltaX = dx
	deltaY = dy
	iterations = 1
	while i+dx >= 0 and j+dy >= 0 and $input[j+dy] != nil and $input[j+dy][i+dx] != nil
		if $input[j+dy][i+dx] == '#' and !$counted[(i+dx)*100 + (j+dy)] and !$destroyed[(i+dx)*100 + (j+dy)]
			$counted[(i+dx)*100 + (j+dy)] = true
			add_angle(i, j, i+dx, j+dy)
		end
		iterations += 1
		dx = iterations*deltaX
		dy = iterations*deltaY
	end
	return 0
end

def perform_raycasts(i, j)
	$counted = []
	$curr_visible = []
	count = 0
	for dy in -$input.length..$input.length
		for dx in -$input[0].length..$input[0].length
			count += raycast(i, j, dx, dy)
		end
	end
	return count
end

perform_raycasts(13, 17)
$keys = $keys.sort.reverse

count = 0
while count < $total_angles
	for key in $keys
		a = $angle[key]
		if a == [] or a == nil
			next
		end
		destroy = a.shift()
		count += 1
		puts 'Count: ' + count.to_s + ' destroy: ' + destroy.to_s
		$destroyed.push(destroy)
	end
end