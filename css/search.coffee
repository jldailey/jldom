
matchesSelector = (tree, node) ->
	ret = []
	for i in tree
		switch typeof i
			when "string"
				op = i[0]
				val = i.substr(1)
				switch op
					when "#"
						if node.id isnt val
							return false
					when "."
						if val not in node.className.split(' ')
							return false
					when ":"
						switch val
							when "first-child"
								if node isnt node.parentNode?.childNodes[0]
									return false
							when "last-child"
								if node isnt node.parentNode?.childNodes[-1]
									return false
			when "object"
				if i instanceof Array
					if not matchesSelector i, node
						return false
				else # is an attribute node
					if node.getAttribute(i.attr) isnt i.val
						return false
	return true

# vim: ft=coffee
