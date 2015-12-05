class FooCLI < Hogun
	desc "hello NAME", "say hello to NAME"
	def hello(name)
		puts "Hello #{name}"
	end
end

FooCLI.start
