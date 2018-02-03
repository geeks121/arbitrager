hash = Hash.new
hash.store(:bf_bid, 30)
hash.store(:bf_ask, 20)
hash.store(:cc_bid, 50)
hash.store(:cc_ask, 60)

puts hash
min, max = hash.minmax { |a, b| a[1] <=> b[1] }
puts min[1]
puts max[1]