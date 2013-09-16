module LightModels

module Ruby

	def self.is_call(node,name=nil,args=nil)
		return false unless node.is_a? Ruby::Call
		return false if name and node.name!=name
		if args
			return false if args.count != node.args.count
			for i in 0..(args.count-1)
				return false unless args[i].eql?(node.args[i])
			end
		end
		true
	end

	def self.is_def(node,name=nil)
		return false unless node.is_a? Ruby::Def
		return false if name and node.name!=name
		true
	end

end

end