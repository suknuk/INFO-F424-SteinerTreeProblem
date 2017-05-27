# Script accepts the first argument as file input
inputFile = ARGS[1]


# Problem size
# var nodes		- how many nodes
# var edges		- how many edges
# var nbTerminals	- how many terminals
# array terminals	- array of terminal numbers

# Adjacency Matrix
# matrix adjMatrix	- 2d matrix holding the graph data


# State variable to determine the current read state of a STP format file
# in the form of SECTION Comment/Graph/Terminals ... END
#
# state = 0 -> no state
#	1 -> Comment state
#		-> Read until END
#	2 -> Graph state
#		-> Read Nodes/Edges numbers, Edge info until END
#	3 -> Terminal state
#		-> Read Terminals number until END
#

state = 0

###############################
# Open file and read every line
f = open(inputFile)
for ln in eachline(f)
	###############
	# waiting state
	###############
	if state == 0
		if ln == "SECTION Comment\n"
			state = 1
		elseif ln == "SECTION Graph\n"
			state = 2
		elseif ln == "SECTION Terminals\n"
			state = 3
		end

	##################
	# in Comment state
	##################
	elseif state == 1
		if ln == "END\n"
			state = 0
		end
	
	################
	# in Graph state
	################
	elseif state == 2
		# Split the line by whitespace into an array
		splitted = split(ln)
		
		# Check for end of state
		if ln == "END\n"
			state = 0
	
		# Check for Nodes line
		elseif splitted[1] == "Nodes"
			global nodes = parse(Int64, "$(splitted[2])")
		
		# Check for Edges line
		elseif splitted[1] == "Edges"
			global edges = parse(Int64, "$(splitted[2])")
			# After reading edges, all info to create the Adjacency Matrix is here
			global adjMatrix = spzeros(nodes,nodes)
			
		# Check for Edge point
		elseif splitted[1] == "E"
			# Read Node numbers and weight
			node1 = parse(Int64, "$(splitted[2])")	
			node2 = parse(Int64, "$(splitted[3])")	
			weight = parse(Int64, "$(splitted[4])")

			# Add entry into Adjacency Matrix
			adjMatrix[node1,node2] = weight
			adjMatrix[node2,node1] = weight
		end

	###################
	# in Terminal state
	###################
	elseif state == 3
		# Split the line by whitespace into an array
		splitted = split(ln)
		
		# Check if end is reached
		if ln == "END\n"
			state = 0

		# Check for Terminal line
		elseif splitted[1] == "Terminals"
			global nbTerminals = parse(Int64, "$(splitted[2])")	
			global terminals = Int64[]			

		# Check for Terminal node line
		elseif splitted[1] == "T"
			# Push terminal number into array that hols all terminals
			terminal = parse(Int64, "$(splitted[2])")	
			push!(terminals, terminal)
		end
	end
end

# Close the input stream
close(f)

println("Nodes $(nodes), edges $(edges), terminals $(length(terminals))")

