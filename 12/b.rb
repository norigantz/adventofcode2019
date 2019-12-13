require 'matrix'

class Matrix
	def []=(i, j, x)
  		@rows[i][j] = x
	end
end

class Universe
	attr_reader :positions, :velocities

	def initialize(positions, velocities)
		@positions = positions.clone
		@velocities = velocities.clone
	end
end

input = File.read('input').split('>')
initial_positions = []
for line in input
	initial_positions.push(line.scan(/(-*\d+)+/))
end

$velocity_mat = Matrix.zero(4, 3)
$position_mat = Matrix[[initial_positions[0][0][0].to_i, initial_positions[0][1][0].to_i, initial_positions[0][2][0].to_i],
					  [initial_positions[1][0][0].to_i, initial_positions[1][1][0].to_i, initial_positions[1][2][0].to_i],
					  [initial_positions[2][0][0].to_i, initial_positions[2][1][0].to_i, initial_positions[2][2][0].to_i],
					  [initial_positions[3][0][0].to_i, initial_positions[3][1][0].to_i, initial_positions[3][2][0].to_i]]
$initial_state = Universe.new($position_mat, $velocity_mat)

def step
	for moonA in 0..$position_mat.row_count-1
		for moonB in 0..$position_mat.row_count-1
			for i in 0..$position_mat.column_count-1
				if moonA < moonB and $position_mat[moonA, i] != $position_mat[moonB, i]
					change = $position_mat[moonA, i] > $position_mat[moonB, i] ? -1 : 1
					$velocity_mat[moonA, i] += change
					$velocity_mat[moonB, i] += -change
				end
			end
		end
	end
	$position_mat = $position_mat + $velocity_mat
end

debugX = Hash.new
debugY = Hash.new
debugZ = Hash.new
count = 0
x_match = 0
y_match = 0
z_match = 0
while x_match == 0 or y_match == 0 or z_match == 0
	step
	count += 1
	x_pos = $position_mat.column(0)
	x_vel = $velocity_mat.column(0)
	y_pos = $position_mat.column(1)
	y_vel = $velocity_mat.column(1)
	z_pos = $position_mat.column(2)
	z_vel = $velocity_mat.column(2)

	if x_match == 0
		if x_pos == $initial_state.positions.column(0) and x_vel == $initial_state.velocities.column(0)
			puts x_pos.inspect
			puts $initial_state.positions.column(0).inspect
			puts x_vel.inspect
			puts $initial_state.velocities.column(0).inspect
			puts 'x_count: ' + count.to_s
			x_match = count
		end
	end
	
	if y_match == 0
		if y_pos == $initial_state.positions.column(1) and y_vel == $initial_state.velocities.column(1)
			puts y_pos.inspect
			puts $initial_state.positions.column(1).inspect
			puts y_vel.inspect
			puts $initial_state.velocities.column(1).inspect
			puts 'y_count: ' + count.to_s
			y_match = count
		end
	end

	if z_match == 0
		if z_pos == $initial_state.positions.column(2) and z_vel == $initial_state.velocities.column(2)
			puts z_pos.inspect
			puts $initial_state.positions.column(2).inspect
			puts z_vel.inspect
			puts $initial_state.velocities.column(2).inspect
			puts 'z_count: ' + count.to_s
			z_match = count
		end
	end
end

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

def LCM(a, b)
	a * b / GCF(a, b)
end

lcm = LCM(z_match, LCM(x_match, y_match))
puts lcm