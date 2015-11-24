require 'combinatorics/choose'

if ARGV.size != 3
  puts "use: #{__FILE__} total_numeros tamanho_sorteio tamanho_objetivo"
  exit
end

n = ARGV[0].to_i
k = ARGV[1].to_i
g = ARGV[2].to_i

possible_nk = Combinatorics::Choose.C(n, k)
possible_ng = Combinatorics::Choose.C(n, g)
possible_kg = Combinatorics::Choose.C(k, g)

puts "Total de cartoes possiveis de #{n} numeros e tamanho #{k}: #{possible_nk}"
puts "Vamos ver como sao esses cartoes possiveis..."
STDIN.gets
combs_nk = (0..n-1).to_a.choose(k).map(&:to_a)
combs_nk.each do |comb|
  p comb
end

puts
puts "Total de combinacoes possiveis de #{n} numeros e tamanho #{g}: #{possible_ng}"
puts "Vamos ver como sao essas combinacoes..."
STDIN.gets
combs_ng = (0..n-1).to_a.choose(g).map(&:to_a)
combs_ng.each do |comb|
  p comb
end

# Isso aqui eh meio magico e só traduzi de haskell pra ruby..
# O que ele faz eh pegar uma combinacao e procurar o indice dela numa tabela de combinacoes
def comb_index(n, k, comb)
  def sum_col(n, k, x)
    return 0 if n == 0 || k == 0 || x == 0
    c = Combinatorics::Choose.C(n - 1, k - 1)
    # esse caco nao ta calculando C direito... enfim
    c = 1 if c == 0
    return c + sum_col(n - 1, k, x - 1)
  end
  def comb_index2(n, k, comb, l)
    return 0 if comb.size == 0
    x = comb.shift
    x2 = x - l - 1
    n2 = n - x2 - 1
    k2 = k - 1
    s = sum_col(n, k, x2)
    return s + comb_index2(n2, k2, comb, x)
  end
  return comb_index2(n, k, comb, -1)
end

puts
puts "Mas cada cartao de #{k} numeros gera #{possible_kg} combinacoes possiveis de #{g} numeros"
puts "Vamos ver como sao essas combinacoes..."
STDIN.gets
combs_kg = (0..k-1).to_a.choose(g).map(&:to_a)
indices = combs_kg.map do |comb|
  idx = comb_index(n, g, comb.clone)
  print "#{comb.inspect} => indice: #{idx}\n"
  idx
end
puts "Indices: #{indices.inspect}"

puts
puts "E se pegarmos todos os cartoes e olharmos para cada combinacao menor que cada um deles gera e dai pegar os indices delas?"
STDIN.gets
# agora tem q pegar todas combinacoes possiveis e ver qual cada um gera das combinacoes menores
indices = combs_nk.map do |ng|
  #puts "ng: #{ng}"
  indices_ng = combs_kg.map do |kg|
    #puts "kg: #{kg}"
    comb = kg.map do |c|
      ng[c]
    end
    comb_index(n, g, comb.clone)
  end
  p indices_ng
  indices_ng
end
#p indices

puts
puts "E se nos colocassemos cada numero na sua propria coluna?"
STDIN.gets
i = 0
indices.map do |comb|
  comb2 = Array.new(possible_ng, '  ')
  comb.each do |c|
    comb2[c] = c.to_s.rjust(2)
  end
  print "#{i.to_s.rjust(2)}: #{comb2.inspect}\n"
  i += 1
end


