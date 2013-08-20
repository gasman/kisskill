#!/usr/bin/ruby -w

require 'perspective'

p = Perspective.new

for y in (0..7)
	skip = p.skipval(y)
	puts "\tdw #{(skip*256).to_i}"
end
