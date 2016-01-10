require 'rubygems'
require 'bundler/setup'
#require 'combinatorics/choose'
Bundler.require(:default)

require './lotery_system.rb'

if ARGV.size != 3
  puts "use: #{__FILE__} total_numeros tamanho_sorteio tamanho_objetivo"
  exit
end

n = ARGV[0].to_i
k = ARGV[1].to_i
g = ARGV[2].to_i

lotery_system = LoterySystem.new(n, k, g)

puts "Total de cartoes possiveis de #{n} numeros e tamanho #{k}: #{lotery_system.possible_nk}"
puts "Vamos ver como sao esses cartoes possiveis..."
STDIN.gets
lotery_system.combs_nk.each do |comb|
  p comb
end

puts
puts "Total de combinacoes possiveis de #{n} numeros e tamanho #{g}: #{lotery_system.possible_ng}"
puts "Vamos ver como sao essas combinacoes..."
STDIN.gets
lotery_system.combs_ng.each do |comb|
  p comb
end

puts
puts "Mas cada cartao de #{k} numeros gera #{lotery_system.possible_kg} combinacoes possiveis de #{g} numeros"
puts "Vamos ver como sao essas combinacoes..."
STDIN.gets
puts "Olhando o primeiro cartao: "
p lotery_system.combs_nk.first
puts "Ele gera as seguintes combinacoes de #{g} em #{g}:"
indices = lotery_system.combs_kg.map do |comb|
  idx = lotery_system.comb_index(n, g, comb.clone)
  print "#{comb.inspect} => indice: #{idx}\n"
  idx
end
puts "Indices: #{indices.inspect}"

puts
puts "E se pegarmos todos os cartoes e olharmos para cada combinacao menor que cada um deles gera e dai pegar os indices delas?"
STDIN.gets
lotery_system.print_indices_nk

puts "\n\n"
puts "Agora vem a loucura e a beleza da matematica... E se eu te disser que essa tabela acima eh formada por outros sistemas de loterias??"
STDIN.gets
lotery_system.print_indices_nk_with_formation
