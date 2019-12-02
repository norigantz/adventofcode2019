sum = 0
File.foreach('input') { |line| sum += line.to_i/3 - 2 }
puts sum