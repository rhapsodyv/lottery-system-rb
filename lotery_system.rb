require 'combinatorics/choose'
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

$debug_formula = false

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

  #       3                   2                 1
  # Soma C(n - 1, p - 1) + C(n - 2, p - 1) + C(n - 3, p - 1) + ... + C(n - k, p - 1) até que x seja 0
  # Ou seja:
  # E C(n - i, p)
  # i=0 ate x
  def sum_col(n, k, x)
    print "\t\tSumCol(n: #{n}, p: #{k}, elemento: #{x})" if $debug_formula
    if x == 0
      puts " = 0"  if $debug_formula
      return 0
    else
      puts ""  if $debug_formula
    end
    c = Combinatorics::Choose.C(n, k)
    puts "\t\t\tC(#{n}, #{k}) = #{c}" if $debug_formula
    # esse caco nao ta calculando C direito... enfim
    c = 1 if c == 0
    n -= 1
    return c + sum_col(n, k, x - 1)
  end

  # Esse metodo faz a magica de descobrir qual é o binomio para iniciar a soma da proxima coluna
  def comb_index2(n, k, comb, last_element)
    puts "\tCombIndex2(n: #{n}, p: #{k}, seq: #{comb}, element_anterior: #{last_element})" if $debug_formula
    return 0 if comb.size == 0

    # pega o elemento atual e remove ele de comb
    current_element = comb.shift

    # diferenca entre os dois elementos indica quantas colunas nos subimos no triangulo de pascal
    diff_cur_last_element = current_element - last_element

    puts "\tcurrent_element: #{current_element}, diff_cur_last_element: #{diff_cur_last_element}" if $debug_formula

    # indica o novo N do sub-conjunto
    new_n = n - diff_cur_last_element

    # indica o novo K do sub-conjunto
    new_k = k - 1

    # realiza a soma dessa coluna
    # ele vai somar: C(n, k) + C(n - 1, k) + C(n-x, k)
    # -1 porque só quero somar o conjunto aberto dos binomios, ou seja, sem incluir o binomio do elemento atual.
    # por exemplo:
    #  diff será sempre maior que 1:
    #  se diff = 1, então é uma sequencia normal: 2,3, logo nao preciso somar nada (1 - 1 = 0)
    #  se diff = 2, então é uma sequencia pulando 1: 2,4, logo preciso somar uma vez (2 - 1 = 1)
    #  se diff = 3, então é uma sequencia pulando 2: 2,5, logo preciso somar duas vezes (3 - 1 = 2)
    #  etc...
    s = sum_col(n, k, diff_cur_last_element - 1)

    # soma recursivamente
    sum = s + comb_index2(new_n, new_k, comb, current_element)
    sum
  end

  def comb_index_binomios(n, k, comb, last_element)
    puts "\tCombIndex2(n: #{n}, p: #{k}, seq: #{comb}, element_anterior: #{last_element})" if $debug_formula
    return [] if comb.size == 0

    # pega o elemento atual e remove ele de comb
    current_element = comb.shift

    # diferenca entre os dois elementos indica quantas colunas nos subimos no triangulo de pascal
    diff_cur_last_element = current_element - last_element

    puts "\tcurrent_element: #{current_element}, diff_cur_last_element: #{diff_cur_last_element}" if $debug_formula

    # indica o novo N do sub-conjunto
    new_n = n - diff_cur_last_element

    # indica o novo K do sub-conjunto
    new_k = k - 1

    # realiza a soma dessa coluna
    # ele vai somar: C(n, k) + C(n - 1, k) + C(n-x, k)
    # -1 porque só quero somar o conjunto aberto dos binomios, ou seja, sem incluir o binomio do elemento atual.
    # por exemplo:
    #  diff será sempre maior que 1:
    #  se diff = 1, então é uma sequencia normal: 2,3, logo nao preciso somar nada (1 - 1 = 0)
    #  se diff = 2, então é uma sequencia pulando 1: 2,4, logo preciso somar uma vez (2 - 1 = 1)
    #  se diff = 3, então é uma sequencia pulando 2: 2,5, logo preciso somar duas vezes (3 - 1 = 2)
    #  etc...
    s = [{n: n, k: k, x: diff_cur_last_element - 1}]

    # soma recursivamente
    sum = s + comb_index_binomios(new_n, new_k, comb, current_element)
    sum
  end


  # Isso aqui eh meio magico e só traduzi de haskell pra ruby..
  # O que ele faz eh pegar uma combinacao e procurar o indice dela numa tabela de combinacoes
  def comb_index(n, k, comb)
    puts "CombIndex(n: #{n}, p: #{k}, seq: #{comb})" if $debug_formula
    # só chama a funcao comb index recursiva passando primeiro elemento da comb
    idx = comb_index2(n - 1, k - 1, comb, -1)
    puts "Index: #{idx}" if $debug_formula
    idx
  end

  # soma binomios até que o total seja o maior valor possivel menor que target.
  # @return [Array] retorna o total e quantos binomios foram somados
  def binomial_sum_until(n, k, target)
    count = 0
    s = 0
    c = 0
    while s < target
      c = Combinatorics::Choose.C(n, k)
      puts "\tC(#{n}, #{k}) = #{c}"
      n -= 1
      s += c
      count += 1
    end
    s -= c

    [s, count]
  end

  def nth_comb2(n, k, idx, last_elment)
    puts "nth_comb(n: #{n}, p: #{k}, idx: #{idx}, last_elment: #{last_elment})"
    return [] if k < 0 || n < 0

    s, count = binomial_sum_until(n, k, idx)
    idx -= s

    # novo n, diminuo quantos binomios a soma "andou"
    new_n = n - count

    # novo k
    new_k = k - 1

    # elemento é o anterior + quantos binomios a soma "andou"
    el = last_elment + count
    [el] + nth_comb2(new_n, new_k, idx, el)
  end

  def nth_comb(n, k, idx)
    nth_comb2(n - 1, k - 1, idx + 1, -1)
  end

  def test_comb_index
    result = self.combs_nk.map{|comb| self.comb_index(self.n, self.k, comb.clone) } == [*(0..self.possible_nk-1)]
    result
  end

  def print_comb(comb)

  end
end
