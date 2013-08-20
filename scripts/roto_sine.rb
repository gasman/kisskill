#!/usr/bin/ruby

# sinewave generator

amplitude = 127
origin = 0
period = 256

sine = []

0.upto(255) do |i|
	sine[i] = (amplitude * Math.sin(i * 2 * Math::PI / period) + origin).to_i % 256
end

0.step(255, 16) do |i|
	puts "\tdb #{sine[i..i+15].join ', '}"
end
