$input = File.read('input').split(/\r?\n/)
$reactions = Hash.new # Key: Material, Value: List of Materials needed
$materials = Hash.new # Key: Material, Value: Amount Available
$materials['ORE'] = -1
$ore_used = 0
$trillion = 1000000000000
$maxC = 0

for reaction in $input
	entries = reaction.split('=>')
	reactants = entries[0]
	reactants = reactants.split(',')
	reactants.map {|s| s = s.gsub!(/ /,'')}
	product = entries[1]
	product = product.gsub!(/ /,'')

	$reactions[product.match(/\D+/).to_s] = reactants
	$reactions[product.match(/\D+/).to_s].unshift(product.match(/\d+/).to_s.to_i)
	if $materials[product.match(/\D+/).to_s] == nil
		$materials[product.match(/\D+/).to_s] = 0
	end
	for i in 1..reactants.length-1
		r = reactants[i]
		if $materials[r.match(/\D+/).to_s] == nil
			$materials[r.match(/\D+/).to_s] = 0
		end
		if r.match(/\d+/).to_s.to_i > $maxC
			r.match(/\d+/).to_s.to_i
		end
	end

	if product.match(/\d+/).to_s.to_i > $maxC
		$maxC = product.match(/\d+/).to_s.to_i
	end
end
$maxC = 1 / $maxC.to_f

def materials_balanced
	balanced = true
	for m in $materials.keys
		if m != 'ORE' and $materials[m] < 0
			balanced = false
		end
	end
	return balanced
end

def balance_materials
	while !materials_balanced
		for m in $materials.keys
			if m != 'ORE' and $materials[m] < 0
				debt = -$materials[m]
				reactants = $reactions[m]
				rep = (debt + reactants[0]-1)/reactants[0]
				$materials[m] += rep*reactants[0]
				for i in 1..reactants.length-1
					n = reactants[i]
					n_val = n.match(/\d+/).to_s.to_i
					n_mat = n.match(/\D+/).to_s
					$materials[n_mat] -= rep*n_val
				end
				break
			end
		end
	end
end

target_fuel = 7863863
$materials.each { |k, v| $materials[k] = 0 }
$materials['FUEL'] = -target_fuel
balance_materials
p $trillion
p -$materials['ORE']
p target_fuel