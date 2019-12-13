require 'matrix'

class Matrix
	def []=(i, j, x)
  		@rows[i][j] = x
	end
end

class Moon
	attr_accessor :position, :velocity

	def initialize(x, y, z)
		@position = Vec3.new(x,y,z)
		@velocity = Vec3.new(0,0,0)
	end

	def update_velocity(moonB)
		if @position.x != moonB.position.x
			change = @position.x > moonB.position.x ? -1 : 1
			@velocity.x += change
			moonB.velocity.x += -change
		end
		if @position.y != moonB.position.y
			change = @position.y > moonB.position.y ? -1 : 1
			@velocity.y += change
			moonB.velocity.y += -change
		end
		if @position.z != moonB.position.z
			change = @position.z > moonB.position.z ? -1 : 1
			@velocity.z += change
			moonB.velocity.z += -change
		end
	end

	def potential_energy
		@position.x.abs + @position.y.abs + @position.z.abs
	end

	def kinetic_energy
		@velocity.x.abs + @velocity.y.abs + @velocity.z.abs
	end

	def total_energy
		potential_energy * kinetic_energy
	end
end

class Vec3
	attr_accessor :x, :y, :z

	def initialize(x=0, y=0, z=0)
		@x = x
		@y = y
		@z = z
	end

	def add(v)
		@x += v.x
		@y += v.y
		@z += v.z
	end
end

input = File.read('input').split('>')
initial_positions = []
for line in input
	initial_positions.push(line.scan(/(-*\d+)+/))
end

Io = Moon.new(initial_positions[0][0][0].to_i, initial_positions[0][1][0].to_i, initial_positions[0][2][0].to_i)
Europa = Moon.new(initial_positions[1][0][0].to_i, initial_positions[1][1][0].to_i, initial_positions[1][2][0].to_i)
Ganymede = Moon.new(initial_positions[2][0][0].to_i, initial_positions[2][1][0].to_i, initial_positions[2][2][0].to_i)
Callisto = Moon.new(initial_positions[3][0][0].to_i, initial_positions[3][1][0].to_i, initial_positions[3][2][0].to_i)

$moons = [Io, Europa, Ganymede, Callisto]

def update_position(moon)
	moon.position.add(moon.velocity)
end

$velocity_mat = Matrix.zero(4, 3)
$position_mat = Matrix[[initial_positions[0][0][0].to_i, initial_positions[0][1][0].to_i, initial_positions[0][2][0].to_i],
					  [initial_positions[1][0][0].to_i, initial_positions[1][1][0].to_i, initial_positions[1][2][0].to_i],
					  [initial_positions[2][0][0].to_i, initial_positions[2][1][0].to_i, initial_positions[2][2][0].to_i],
					  [initial_positions[3][0][0].to_i, initial_positions[3][1][0].to_i, initial_positions[3][2][0].to_i]]
def step_matrix
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

def total_energy
	total = 0
	for i in 0..$position_mat.row_count-1
		potential = 0
		kinetic = 0
		for j in 0..$position_mat.column_count-1
			potential += $position_mat[i, j].abs
			kinetic += $velocity_mat[i, j].abs
		end
		total += potential*kinetic
	end
	total
end

def step
	for moonA in 0..$moons.length-1
		for moonB in 0..$moons.length-1
			if moonA < moonB
				$moons[moonA].update_velocity($moons[moonB])
			end
		end
	end
	for moon in $moons
		update_position(moon)
	end
end

count = 0
while count < 1000
	step
	step_matrix
	count += 1
end
puts Io.total_energy + Europa.total_energy + Ganymede.total_energy + Callisto.total_energy
puts total_energy
