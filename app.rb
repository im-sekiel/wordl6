require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'puma'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

helpers do
  def is_nil?(letter)
    letter == nil
  end

  def num_of_squares
    42
  end

  def shift_index(index)
    index % 6
  end

  def choose_color(letter, word, index)
    index = shift_index(index)
    # In the case that the current square is empty/nil
    return "none" if letter == nil 

    if word[index].upcase == letter
      session[:greenlist] << letter
      "green"
    elsif word.include?(letter.downcase)
      session[:yellowlist] << letter
      "yellow"
    else
      session[:graylist] << letter
      "gray"
    end
  end

  def congrats(string)
    if string == congrats_message
      "congrats"
    else
      "error"
    end
  end

  def key_color(key)
    if session[:greenlist].include?(key)
      "green" 
    elsif session[:yellowlist].include?(key)
      "yellow"
    elsif session[:graylist].include?(key)
      "gray"
    else
      ""
    end
  end

  def average_guess
    return 0 if session[:average].size == 0
    (session[:average].sum / session[:average].size.to_f)
  end

  def games_played
    @list.index(session[:current_word])
  end

  def win_rate_percent
    return games_played if games_played == 0

    ((session[:wins] / games_played.to_f) * 100).round
  end
end

before do 
  @alphabet = ('A'..'Z').to_a
  @list = File.read('words.txt').split
  session[:current_lineup] ||= []
  session[:current_word] ||= @list[0]
  session[:next] ||= false
  session[:greenlist] ||= []
  session[:yellowlist] ||= []
  session[:graylist] ||= []
  session[:wins] ||= 0
  session[:streak] ||= 0
  session[:maxstreak] ||= 0
  session[:average] ||= []
end

def valid_word?(word)
  selected = word.chars.select do |char|
    @alphabet.include?(char.upcase)
  end.join

  @list.include?(word.downcase) && selected.size == 6
end

def append_chars(array, word)
  word.chars.each do |char|
    array << char
  end
end

def next_word(list)
  current_index = list.find_index(session[:current_word])
  current_index += 1
  session[:current_word] = list[current_index]
end

def congrats_message
  "Congratulations! Press Enter to Continue."
end

def guesses(attempts)
  attempts.size / 6 
end

def reset
  session[:current_lineup] = []
  next_word(@list)
  session[:next] = false
  session[:greenlist] = []
  session[:yellowlist] = []
  session[:graylist] = []
end

def update_maxstreak
  session[:maxstreak] = session[:streak] if session[:maxstreak] < session[:streak]
end

# ROUTES
get '/' do
  update_maxstreak

  erb :index
end

post '/word' do
  word = params[:answer].upcase

  if session[:current_lineup].size >= 36
    reset
    session[:message] = "Better luck next time"
    session[:streak] = 0
    session[:average] << 7 #max attempts
    redirect '/'
  end

  if valid_word?(word)
    append_chars(session[:current_lineup], word)
    if word == session[:current_word].upcase
      session[:next] = true
      session[:message] = congrats_message()
      session[:average] << guesses(session[:current_lineup])
      session[:wins] += 1
      session[:streak] += 1
    end
  else
    session[:message] = "Not a valid word."
  end

  # erb :index
  redirect "/"
end

post '/next' do
  reset

  redirect '/'
end