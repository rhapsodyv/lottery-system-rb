
# Arruma um bug na lib Combinatorics que por algum motivo louco retorna C(x, 0) = 0, mas é 1!!
module Combinatorics
  module Choose
    def self.C(n, r)
      # tratamento de numeros negativos que tbm nao tem na lib
      return 0 if n < 0 || r < 0 || n < r
      #puts "C(#{n}, #{r})"
      # otimizacao do calculo de combinacao simples:
      #   da pra simplificar parte do calculo cortando o fatorial de n-r em baixo e em cima
      #
      # n*(n-1)*(n-2)*..//(n-r)!//
      # +----------------------+
      #       r!*//(n-r)!//
      #
      #Math.factorial(n) / (Math.factorial(r) * Math.factorial(n - r))
      Math.pi((n-r+1)..n) / Math.factorial(r)
    end
  end
end

class LoterySystem
  attr_reader :n, :k, :g
  attr_reader :possible_nk, :possible_ng, :possible_kg
  attr_reader :combs_nk, :combs_ng, :combs_kg

  def initialize(n, k, g)
    @n = n
    @k = k
    @g = g

    @possible_nk = Combinatorics::Choose.C(n, k)
    @possible_ng = Combinatorics::Choose.C(n, g)
    @possible_kg = Combinatorics::Choose.C(k, g)

    @combs_nk = (0..n-1).to_a.choose(k).map(&:to_a)
    @combs_ng = (0..n-1).to_a.choose(g).map(&:to_a)
    @combs_kg = (0..k-1).to_a.choose(g).map(&:to_a)

    @pad = (@possible_ng - 1).to_s.size + 1
    gen_all_indices_nk
  end

  def print_indices_nk(color = nil)
    i = 0

    @all_indices_nk.map do |comb|
      comb2 = Array.new(@possible_ng, ' ' * @pad)
      comb.each do |c|
        comb2[c] = c.to_s.rjust(@pad)
      end

      print "#{i.to_s.rjust(2)}: ["
      comb2.each_with_index do |c, idx|
        print c.colorize(color)
      end
      print "]\n"
      #print "#{i.to_s.rjust(2)}: #{comb2.inspect}\n"
      i += 1
    end
  end

  def print_indices_nk_with_formation
    left =   LoterySystem.new(n - 1, k - 1, g - 1)
    right =  LoterySystem.new(n - 1, k - 1, g    )
    bottom = LoterySystem.new(n - 1, k    , g    )

    i = 0
    @all_indices_nk.map do |comb|
      comb2 = Array.new(@possible_ng, ' ' * @pad)
      comb.each do |c|
        comb2[c] = c.to_s.rjust(@pad)
      end

      print "#{i.to_s.rjust(2)}: ["
      comb2.each_with_index do |c, idx|
        color = :green
        if idx >= left.possible_ng
          color = :red
        end
        if i >= left.possible_nk
          color = :blue
        end
        print c.colorize(color)
      end
      print "]\n"

      i += 1
    end

    puts "Esquerda: #{left.n} #{left.k} #{left.g}"
    left.print_indices_nk(:green)
    puts "Direita : #{right.n} #{right.k} #{right.g}"
    right.print_indices_nk(:red)
    puts "Em baixo: #{bottom.n} #{bottom.k} #{bottom.g}"
    bottom.print_indices_nk(:blue)
  end

  def gen_all_indices_nk
    @all_indices_nk = @combs_nk.map do |nk|
      #puts "nk: #{nk}"
      indices_nk = @combs_kg.map do |kg|
        #puts "kg: #{kg}"
        comb = kg.map do |c|
          nk[c]
        end
        comb_index(@n, @g, comb.clone)
      end
      indices_nk
    end
  end

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

  # Isso aqui eh meio magico e só traduzi de haskell pra ruby..
  # O que ele faz eh pegar uma combinacao e procurar o indice dela numa tabela de combinacoes
  def comb_index(n, k, comb)
    return comb_index2(n, k, comb, -1)
  end

  def print_comb(comb)

  end
end