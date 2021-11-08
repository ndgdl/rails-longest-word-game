require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    alphabet = ('A'..'Z').to_a
    @letters = []
    10.times { @letters << alphabet.sample }
    @score = cookies[:score].to_i || 0
  end

  def score
    @letters = params[:letters].split(' ')
    @attempt = params[:word].upcase if params[:word]
    @score = cookies[:score].to_i || 0

    unless all_in_the_grid?(@attempt, @letters) && english_word?(@attempt)
      status = !all_in_the_grid?(@attempt, @letters) ? "can't be built out of #{@letters.join(', ')}" : 'does not seem to be an english word...'
      return @message = "Sorry but #{@attempt} #{status}"
    end
    @message = "Congratulations! #{@attempt} is a valid English word"
    @score += @attempt.length * 10
  end

  def all_in_the_grid?(word, array)
    word.upcase.split('').all? do |letter|
      array.include?(letter) && word.count(letter) <= array.count(letter)
    end
  end

  def english_word?(word)
    api_url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_api = JSON.parse(URI.open(api_url).read)
    word_api['found']
  end
end
