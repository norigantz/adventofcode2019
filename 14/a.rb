$input = File.read('input').split(/\r?\n/)
$reactions = Hash.new # Key: Material, Value: List of Materials needed
$materials = Hash.new # Key: Material, Value: Amount Available
$ore_used = 0
$materials['ORE'] = -1

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
	end
end

def get_reactants(product)
	if $reactions[product.match(/\D+/).to_s] == nil
		p 'No reaction found with given product: ' + product.match(/\D+/).to_s
	end
	$reactions[product.match(/\D+/).to_s]
end

def get_available_material(material)
	if $materials[material.match(/\D+/).to_s] == nil
		p 'No material found with given material code: ' + material.match(/\D+/).to_s
	end
	$materials[material.match(/\D+/).to_s]
end

# puts $reactions.inspect

def produce_material(product)
	material = product.match(/\D+/).to_s
	reactants = get_reactants(product)
	coefficient = reactants[0]
	for i in 1..reactants.length-1
		n = reactants[i]
		p n
		n_val = n.match(/\d+/).to_s.to_i
		n_mat = n.match(/\D+/).to_s
		if $materials[n_mat] == -1
			$materials[material] += coefficient
			p coefficient.to_s + ' ' + material + ' produced using ' + n_val.to_s + ' ' + n_mat
			$ore_used += n_val
			return
		end
		while $materials[n_mat] < n_val
			produce_material(n)
		end
		$materials[n_mat] -= n_val
	end
	# for i in 1..reactants.length-1
		# n = reactants[i]
		# n_val = n.match(/\d+/).to_s.to_i
		# n_mat = n.match(/\D+/).to_s
		# $materials[n_mat] -= n_val
	# end
	$materials[material] += coefficient
	p coefficient.to_s + ' ' + material + ' produced using ' + reactants.to_s
end

produce_material('FUEL')

p $ore_used