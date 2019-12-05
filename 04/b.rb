Min = 168630
Max = 718098

class Hash
	def self.numdigits(num)
		count = 0
		n = num
		while n != 0
			n /= 10
			count += 1
		end
		count
	end

	def self.digit(i, num)
		(num % (10**i))/10**(i-1) unless i <= 0 or i > 6
	end

	def self.valid(num)
		cond_match = false
		cond_rank = true
		prev = num
		matchCounts = [0,0,0,0,0,0,0,0,0,0]
		for i in 1..6
			if prev == digit(i, num)
				matchCounts[prev] += 1
			end
			if prev < digit(i, num)
				return false
			end
			prev = digit(i, num)
		end
		matchCounts.map!{|i| i += 1}
		if matchCounts.include?(2)
			cond_match = true
		end
		cond_match && cond_rank
	end
end

count = 0
for i in Min..Max
	if Hash.valid(i)
		count += 1
	end
end
puts count