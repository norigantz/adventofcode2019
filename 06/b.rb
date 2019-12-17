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

you = nodeHash['YOU']
san = nodeHash['SAN']

def orbitCount(node, depth)
	if node == nil
		return
	end

	node.orbit_count = depth
	for sat in node.satellites
		orbitCount(sat, depth+1)
	end
end

def minDist(dist, nodes)
	minNode = nodes.first
	for node in nodes
		if dist[node[0]] < dist[minNode[0]]
			minNode = node
		end
	end
	return minNode
end

def dijkstra(graph, source)
	dist = Hash.new
	dist[source.label] = 0
	queue = []
	for node in graph
		if node[0] == source.label
			queue.push(node)
			next
		end
		dist[node[0]] = 999999
		queue.push(node)
	end

	while queue.any?
		v = minDist(dist, queue)
		queue.delete(v)

		neighbors = v[1].satellites
		neighbors.push(v[1].parent)
		for neighbor in neighbors
			if neighbor == nil
				next
			end
			alt = dist[v[0]] + 1
			if alt < dist[neighbor.label]
				dist[neighbor.label] = alt
			end
		end
	end
	return dist
end

dist = djikstra(nodeHash, you)
puts dist['SAN'] - 2