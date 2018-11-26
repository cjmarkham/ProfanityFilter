require 'json'
require "profanityfilter/version"

module Profanityfilter
  class Error < StandardError; end

  @profane_words = []
  # Map symbols to their letter counterpart
  @symbol_map = [{
    symbol: '$',
    letter: 's',
  }, {
    symbol: '!',
    letter: 'i',
  }, {
    symbol: '1',
    letter: 'i',
  }]

  def self.sanitize string
    # Load all of the JSON words
    self.load_words

    sanitized = self.sanitize_spaces string
    sanitized = self.sanitize_concurrent_letters sanitized
    self.sanitize_symbols sanitized
  end

  def self.load_words
    path = './profanityfilter/words.json'
    json = File.read(File.expand_path(path, File.dirname(__FILE__)))
    @profane_words = JSON.parse json
  end

  # Sanitizes profane words which have been split with spaces
  def self.sanitize_spaces string
    # For simplicity, we remove all duplicate spaces
    string_without_concurrency = string.gsub /(\s)\1+/i, "\\1"

    # Loop through all words in our profanity dictionary
    @profane_words.each do |word|
      # Get all varients of this word with spaces
      spaced_varients = self.add_spaces_to_word word

      spaced_varients.each do |spaced|
        # We need to replace any symbols in the string
        # This is pretty much the same as the symbol sanitization below
        # but we need to do this here too as that method is called after this
        # and relies on space removal
        string_without_concurrency.split(//).each_with_index do |letter, index|
          replacement = @symbol_map.find {|k, v| k[:symbol] == letter }

          # If there is a replacement, replace the letter in the word
          # with the replacement
          # We dont want to directly replace the word as this symbol
          # could be a legit one
          if replacement
            # If the symbol is at the end of the word, leave it
            # This is an assumption that the last symbol is a legit one (!)
            if index == string_without_concurrency.length - 1
              next
            end

            # Replace the symbol with the letter in the string at this index
            string_without_concurrency[index] = replacement[:letter]
          end
        end

        # If the spaced word appears in the string, remove it
        if matched = string_without_concurrency.match(spaced)
          string_without_concurrency.gsub! matched.to_s, '*' * matched.to_s.gsub(/\s/, '').length
        end
      end
    end

    string_without_concurrency
  end

  # This method replaces symbols with their letter counterpart and then
  # sanitizes the word if it appears in the profanity list
  def self.sanitize_symbols string
    words = string.split /\s/

    words.each do |word|
      letters = word.split //
      new_word = nil

      letters.each_with_index do |letter, index|
        # Find the symbol hash that matches this symbol
        replacement = @symbol_map.find {|k, v| k[:symbol] == letter }

        # If there is a replacement, replace the letter in the word
        # with the replacement
        # We dont want to directly replace the word as this symbol
        # could be a legit one
        if replacement
          # If the symbol is at the end of the word, leave it
          if index == word.length - 1
            next
          end

          # If we have already replaced a letter in this word, we
          # need to use the word stored in new_word
          # We need to replace just the symbol at this index as there
          # may be legit symbols in this word that are the same
          new_word = word.dup if new_word.nil?
          new_word[index] = replacement[:letter]
        end
      end

      # There were no symbols that were replaced in this word
      next if new_word.nil?

      # Check if this word should be sanitized
      sanitize_check = self.sanitize_word new_word.downcase

      # If it should, replace the word with the sanitized version
      if sanitize_check[:is_sanitized]
        string.gsub! word.downcase, sanitize_check[:sanitized]
      end
    end

    string
  end

  # Sanitizes words with concurrent letters
  def self.sanitize_concurrent_letters string
    words = string.split /\s/

    words.each do |word|
      # Remove all concurrent letters then check this new word with the
      # list of profanities
      word_without_concurrency = word.gsub /(\w)\1+/i, "\\1"
      sanitize_check = self.sanitize_word word_without_concurrency

      if sanitize_check[:is_sanitized]
        string.gsub! word, sanitize_check[:sanitized]
      end
    end

    string
  end

  # Checks a single word against the list of words, returning meta
  # data based on the sanitization
  def self.sanitize_word word
    is_sanitized = false
    # Remove concurrent letters
    # If multiple symbols were used they will be replaced
    # with letters and there will be concurrency
    word_without_concurrency = word.downcase.gsub /(\w)\1+/i, "\\1"

    # Find the word in the list that matches this word
    # We use length of the word to check as this word may have a trailing
    # symbol such as an exclaimation mark
    profanity_match = @profane_words.select {|w| w == word_without_concurrency[0..w.length - 1] }

    if profanity_match[0]
      is_sanitized = true
      # Replace the string with asteriks for the length
      sanitized = word_without_concurrency.gsub(profanity_match[0], '*' * profanity_match[0].length)
    end

    {
      original: word_without_concurrency,
      is_sanitized: is_sanitized,
      sanitized: sanitized,
    }
  end

  # This takes a word and returns each version of that word with
  # spaces seperating each letter, with a min of 1 space and a max
  # of word length - 1
  def self.add_spaces_to_word word
    return [word] if word.size == 1
    first_char = word[0]
    add_spaces_to_word(word[1..-1]).flat_map do |s|
      [first_char + s, first_char + ' ' + s]
    end
  end
end
