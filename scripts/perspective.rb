#!/usr/bin/ruby -w

class Perspective
	TEX_HEIGHT = 256
	VIEW_ANGLE = 45*Math::PI/180
	ELEVATION = 30*Math::PI/180
	HEIGHT = 8

	def initialize
		# distance from eye to projection screen
		@d = HEIGHT / (2 * Math.tan(VIEW_ANGLE/2))
		
		# ratio of distance-covered-by-texmap to height-of-sky
		@td = 1/(Math.tan(ELEVATION - VIEW_ANGLE/2)) - 1/(Math.tan(ELEVATION + VIEW_ANGLE/2))
		
		# ratio of horizontal-distance-to-nearpoint-of-visible-sky to height-of-sky
		@x0 = 1 / (Math.tan(ELEVATION + VIEW_ANGLE/2))
	end
	
	def vval(y)
		elevation_from_eye = Math.atan(((HEIGHT/2) - y) / @d)
		total_elevation = ELEVATION + elevation_from_eye
		x = 1/(Math.tan(total_elevation))
		v = (x - @x0) * TEX_HEIGHT / @td
	end
	
	def skipval(y)
		elevation_from_eye = Math.atan(((HEIGHT/2) - y) / @d)
		total_elevation = ELEVATION + elevation_from_eye
		skip = Math.cos(elevation_from_eye) * TEX_HEIGHT / (@td * @d * Math.sin(total_elevation))
	end
end

#p = Perspective.new
#for y in (0..23)
#	puts "y = #{y} => v = #{p.vval(y)}, skip => #{p.skipval(y)}"
#end