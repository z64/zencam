module ZenCam
  # Methods for generating gcode-style language
  module GCode
    # Regex patterns for parsing GCode
    REGEX = {
      words:  /([a-zA-Z])(.+)/,
      blocks: /[a-zA-Z]-?[\d]*\.?[\d]*/
    }.freeze

    # A word in a block of GCode
    class Word
      # @return [String] the letter address of the Word
      attr_accessor :address

      # @return [Anything] the data attached to the Word
      attr_accessor :data

      def initialize(address, data)
        @address = address
        @data    = data
      end

      # Renders a Word to a string.
      # @return [String]
      def to_s
        "#{address}#{data}"
      end

      # Attempts to parse a string into a new Word object.
      #
      # @param data [String] the text to convert.
      # @return [Word]
      def self.from_str(data)
        match = data.match(REGEX[:words]).to_a
        match[2] = match[2].include?('.') ? match[2].to_f : match[2].to_i
        new(match[1], match[2])
      end
    end

    # A collection of words in a line of GCode
    class Block
      # @return [Array<Word>] the words that make up this Block
      attr_accessor :words

      # @return [String] the seperator to be used between words when rendering with #to_s
      attr_accessor :seperator

      def initialize(words = [], seperator: ' ')
        @words = words
        @seperator = seperator
      end

      # @return [String] the rendered Block as a String
      def to_s
        words.map(&:to_s).join(seperator)
      end

      # Attempts to parse a String block back into a Block object.
      #
      # @param data [String] the text to convert
      # @return [Block]
      def self.from_str(data)
        data = data.scan(REGEX[:blocks])
        new(data.map { |w| Word.from_str(w) })
      end
    end
  end
end
