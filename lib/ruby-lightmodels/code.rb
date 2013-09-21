module LightModels

module Ruby

def self.to_code(node)
	on = node.original_node
	sw = java.io.StringWriter.new
	rwv = org.jrubyparser.rewriter.ReWriteVisitor.new(sw,'')
	cbw = org.jrubyparser.rewriter.ClassBodyWriter.new(rwv,on)
	cbw.write
	sw.to_string
end

end

end