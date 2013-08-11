module RubyMM

	verbose = false

	def self.is_call(node,name=nil,args=nil)
		return false unless node.is_a? RubyMM::Call
		return false if name and node.name!=name
		if args
			return false if args.count != node.args.count
			for i in 0..(args.count-1)
				#puts "CHECKING #{i} #{args[i]} vs #{node.args[i]}"
				#puts "\t#{args[i].class}"
				#puts "\t#{node.args[i].class}"
				#Fallisce per via della compare fra le stringhe
				#puts "Returning false " unless args[i].eql?(node.args[i])
				return false unless args[i].eql?(node.args[i])
			end
		end
		#puts "OK!"
		true
	end

end