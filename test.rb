# alphabet = ('A'..'Z').to_a
# WORDS = @words = File.read('words.txt').split

# def valid_word?(word)
#   alphabet = ('A'..'Z').to_a

#   selected = word.chars.select do |char|
#     alphabet.include?(char.upcase)
#   end.join

#   WORDS.include?(word.downcase) && selected.size == 6
# end

# p valid_word?("Worlds")
#  

array = []

42.times do |num|
  puts num % 6
end