hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
hash[:bitflyer][:bid][:price] = 30
hash[:bitflyer][:bid][:size] = 0.1
hash[:bitflyer][:ask][:price] = 25
hash[:bitflyer][:ask][:size] = 0.2
hash[:coincheck][:bid][:price] = 40
hash[:coincheck][:bid][:size] = 0.3
hash[:coincheck][:ask][:price] = 35
hash[:coincheck][:ask][:size] = 0.4

puts hash[:bitflyer][:bid][:price]
puts hash.keys
puts hash.values