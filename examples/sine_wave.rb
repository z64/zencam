require 'yaml'
require_relative '../lib/zencam'

# Create a new post-processor
POST = ZenCam::Post.new(YAML.load_file('../posts/generic.yaml'))

# Container for the program blocks
program = []

# Program header comment
program << POST.block(1, nil, nil, comment: 'sine wave example')

# A simple sine-wave stepper class
class Wave
  attr_reader :position
  attr_reader :step

  def initialize(position = 0.0, step = 0.05)
    @position = position
    @step = step
  end

  def walk!
    @position += step
  end
end

# Create a new Wave, and generate GCode
wave = Wave.new
steps = 150
steps.times do |t|
  program << POST.block(
    t + 2,
    :linear,
    nil,
    words: {
      x: wave.position.round(4),
      y: Math.sin(wave.position).round(4),
      feed: 1.0
    }
  )
  wave.walk!
end

# Output the program
puts program
