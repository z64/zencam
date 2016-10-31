require_relative 'gcode'

module ZenCam
  # A post processor
  class Post
    # The hash of the config this Post was initialized with.
    attr_reader :data

    # Initialize a new post processor with the supplied
    # data hash. This hash should have all of the machine-specific
    # GCode formatting required to make the machine operate
    # as expected by the programmer.
    def initialize(data)
      @data = data
    end

    #############
    # ADDRESSES #
    #############

    # Pulls an address from the loaded post
    #
    # @param a [Symbol, #to_s]
    def address(a)
      data['address'][a.to_s]
    end

    # Creates a Word with a specified address
    # and value
    #
    # @param a [Symbol, #to_s] the address key
    # @param v [Anything, #to_s] the value to attach to the Word
    # @return [GCode::Word]
    def word(a, v)
      GCode::Word.new(
        address(a),
        v
      )
    end

    # Creates a Word prefixed with the prep address
    # and value picked from the list of prep codes
    #
    # @param g [Symbol, #to_s] the associage prepatory address key
    # @return [GCode::Word]
    def prep(g)
      value = data['gcodes'][g.to_s]
      word(:prep, value) unless value.nil?
    end

    # Creates a Word prefixed with the function address
    # and value picked from the list of function codes
    #
    # @param m [Symbol, #to_s] the associated function address key
    # @return [GCode::Word]
    def function(m)
      value = data['mcodes'][m.to_s]
      word(:function, value) unless value.nil?
    end

    # Creates a sequence word
    #
    # @param n [Integer] the sequence number
    # @return [GCode::Word]
    def sequence(n)
      word(:sequence, n) unless n.nil?
    end

    # Creates a comment word string
    #
    # @param text [String]
    # @return [String] the same text, stylized according to the post processor
    def comment(text = nil)
      return if text.nil?
      "#{data['comment']['left']}"\
      "#{text.upcase}"\
      "#{data['comment']['right']}"
    end

    ##########
    # BLOCKS #
    ##########

    # Creates a Block for machine control.
    #
    # @param sequence [Integer] the sequence of this block
    # @param prep [Symbol] the prepatory (G-code) word to use
    # @param function [Symbol] the function (M-code) word to use
    # @param words [Hash] an arbitary list of addresses and values to create words from
    # @param before [Anything] anything you'd like to inject before the block, typically a Word, for example, a G90.
    # @param comment [String] a comment to append to the end of the block
    # @return [GCode::Block]
    def block(sequence = nil, prep = nil, function = nil, words: {}, before: nil, comment: nil)
      # New block to return
      block = GCode::Block.new

      # Assemble the block
      block.words = [
        sequence(sequence),
        before,
        prep(prep),
        words.collect { |k, v| word(k, v) },
        function(function),
        comment(comment)
      ].compact.flatten

      # Pass the block back to the caller
      block
    end
  end
end
