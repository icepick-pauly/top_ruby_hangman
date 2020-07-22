require 'json'

class Hangman

  def initialize
    @word = words.sample
    @lives = 7
    @word_teaser = ''

    (@word.size-1).times do
      @word_teaser += '_ '
    end
  end

  def get_save_path(file_name)
    "../save_files/" + file_name + '.json'
  end

  def save_game(file_path)
    game_save = {
      word: @word,
      lives_left: @lives,
      word_teaser: @word_teaser,
    }

    File.open(file_path, "w") do |f|
      f.write(game_save.to_json)
    end
  end

  def ask_user_save
    puts 'Are you sure you want to save your game?'
    answer = gets.chomp.strip.downcase

    if answer == 'yes'
      puts 'What name would you like to save it under?'
      loop do
        file_name = gets.chomp.strip.gsub(/\s+/, '_')
        file_path = get_save_path(file_name)

        if File.file?(file_path)
          puts 'A save with that name already exists! Please pick another name.'
        else
          save_game(file_path)
          break
        end
      end
    end
  end

  def load_game(file_path)
    save_data = JSON.parse(File.read(file_path), symbolize_names: true)
    @word = save_data[:word]
    @lives = save_data[:lives_left]
    @word_teaser = save_data[:word_teaser]
  end

  def ask_user_load
    # Do not ask to load a save file if there are none available
    unless Dir.empty?('../save_files')
      puts 'Do you want to load a saved game? (Y/N)'
      load_game_answer = gets.chomp.strip.downcase

      if load_game_answer == 'y'
        puts 'Here ate the available save files'

        # prints all the file names of save files
        Dir.each_child('../save_files') do |file_name|
          name_without_extension = File.basename(file_name, '.json')
          puts '- ' + name_without_extension
        end

        # Gets name of file user wants to load
        puts 'What file would you like to load?'
        loop do
          file_name = gets.chomp.strip
          file_path = get_save_path(file_name)

          if File.file?(file_path)
            load_game(file_path)
            puts 'Successfully loaded file'
            break
          else
            puts 'Please enter one the save file names listed previously'
          end
        end
      end
    end
  end


  def words
    words = File.readlines '../words.csv'
    filtered_words = words.select {|word| word.length >= 5 && word.length <= 12}

    filtered_words
  end

  def stick_figure
    if @lives == 7
      puts "
      ____
     |    |
     |
     |
     |
     |
     |
_____|_____
"
    elsif @lives == 6
      puts "
      ____
     |    |
     |    O
     |
     |
     |
     |
_____|_____
"
    elsif @lives == 5
      puts "
      ____
     |    |
     |  __O
     |
     |
     |
     |
_____|_____
"
    elsif @lives == 4
      puts "
      ____
     |    |
     |  __O__
     |
     |
     |
     |
_____|_____
"
    elsif @lives == 3
      puts "
      ____
     |    |
     |  __O__
     |    |
     |
     |
     |
_____|_____
"
    elsif @lives == 2
      puts "
      ____
     |    |
     |  __O__
     |    |
     |   /
     |
     |
_____|_____
"
    elsif @lives == 1
      puts "
      ____
     |    |
     |  __O__
     |    |
     |   / \\
     |
     |
_____|_____
"
    elsif @lives == 0
      puts "
      ____
     |    |
     |  __0__
     |    |_
     |   / \\
     |
     |
_____|_____
"
    end
  end

  def print_teaser(last_guess = nil)
    update_teaser(last_guess) unless last_guess.nil?
    puts @word_teaser
  end

  def update_teaser(last_guess)
    new_teaser = @word_teaser.split

    new_teaser.each_with_index do |letter, index|
      # replace blank values with correct guess if there is a match
      if letter == '_' && @word[index] == last_guess
        new_teaser[index] = last_guess
      end
    end

    @word_teaser = new_teaser.join(' ')
  end

  def game_won?
    #checks that every letter ahs been guessed
    @word.split('').each do |letter|
      unless @word_teaser.include?(letter)
        return false
      end
    end

    true
  end

  def make_guess
    if @lives > 0
      puts 'Enter a letter!'
      guess = gets.chomp.downcase

      # if letters is part of word then remove from letter array
      good_guess = @word.include?(guess)

      if guess == 'exit'
        puts 'Thanks for playing!'
      elsif guess == 'save'
        ask_user_save
      elsif good_guess
        puts "You are correct! #{guess} is in the word!"
        stick_figure

        print_teaser(guess)

        if game_won?
          puts 'Congratulations! You have won this round!'
        else
          make_guess
        end
      else
        @lives -= 1
        puts "Sorry... You have #{@lives} guesses left, try again!"
        stick_figure
        print_teaser
        make_guess
      end
    else
      puts "Game over! The word was #{@word} Better luck next time"
    end
  end

  def begin
    # ask user for a letter
    puts "Welcome to HUNG"
    ask_user_load
    puts "Your word is #{@word.size-1} letters long!"
    puts "To exit game at any point, type 'exit' to end the game.."
    puts "To save your game where you left off, type 'save'.."
    puts "Good luck!"
    stick_figure
    print_teaser

    make_guess
  end

end

game = Hangman.new
game.begin
