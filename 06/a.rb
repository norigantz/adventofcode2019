class Node
	attr_accessor :label, :parent, :satellites, :orbit_count, :visited

	def initialize(label)
		@label = label
		@orbit_count = 0
		@satellites = []
		@visited = false
	end

	def set_parent(parent)
		@parent = parent
		@parent.satellites.push(self)
	end
end

input = File.read('input').split(' ')

nodeHash = Hash.new
debugCount = 0
for pair in input
	pair = pair.split(')')

	if nodeHash.has_key?(pair[1])
		satellite = nodeHash[pair[1]]
	else
		satellite = Node.new(pair[1])
		nodeHash[pair[1]] = satellite
	end
	
	if nodeHash.has_key?(pair[0])
		satellite.set_parent(nodeHash[pair[0]])
	else
		nodeHash[pair[0]] = Node.new(pair[0])
		satellite.set_parent(nodeHash[pair[0]])
	end
end

for node in nodeHash
	if node[1].parent == nil
		root = node[1]
	end
end

def orbitCount(node, depth)
	if node == nil
		return
	end

	node.orbit_count = depth
	for sat in node.satellites
		orbitCount(sat, depth+1)
	end
end

orbitCount(root, 0)

sum = 0
nodeHash.each {|key, value| sum += value.orbit_count}
puts sum