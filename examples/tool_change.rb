require 'yaml'
require_relative '../lib/zencam'

# Create a new post-processor
POST = ZenCam::Post.new(YAML.load_file('../posts/generic.yaml'))

# Wrap the post processor to generate tool change code
def tool_change(_n, description = '', seq: 1)
  [
    POST.block(seq, nil, nil, words: { tool: 6 }, comment: description),
    POST.block(seq + 1, nil, :tool_change)
  ]
end

puts POST.block(1, comment: 'tool change')

# Execute the tool change
puts tool_change(6, '0.25 dia endmill', seq: 2)

# Output:
# N1 (TOOL CHANGE)
# N2 T6 (0.25 DIA ENDMILL)
# N3 M6
