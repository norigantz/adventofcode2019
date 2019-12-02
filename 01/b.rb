def fuel(f, total=0)
	amt = f/3 - 2
	amt <= 0 ? total : fuel(amt, total + amt)
end

sum = 0
File.foreach('input') { |line| sum += fuel(line.to_i) }
puts sum