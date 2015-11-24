require 'combinatorics/choose'

if ARGV.size != 2
  puts "use: #{__FILE__} total_numbers draw_size"
  exit
end

n = ARGV[0].to_i
k = ARGV[1].to_i
#g = ARGV[2].to_i

possible_combs = Combinatorics::Choose.C(n, k)
puts "Total possibile combinations: #{possible_combs}"
puts "Lets see the how look like the combinations... "
STDIN.gets
combs = (0..n-1).to_a.choose(k).map(&:to_a)
combs.each do |comb|
  p comb
end

puts "\nWhat if we arrange each number in their own column?"
STDIN.gets

combs.map do |comb|
  comb2 = Array.new(n, ' ')
  comb.each do |c|
    comb2[c] = c.to_s
  end
  p comb2
end


