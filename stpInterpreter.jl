#####################################################
# Raymond Lochner 2017
# The provided readArgumentFile() function creates
# the required variables and an Adjacency Matrix from
# a Steiner Tree Problem (STP) specified file
#
# Does not check the validity of the STP file
#####################################################


# The function creates the following global variables
# Int64 nodes		- how many nodes
# Int64 edges		- how many edges
# Int64[] terminals	- Int64 array of terminal numbers

# Adjacency Matrix
# matrix adjMatrix	- 2d Int64 matrix holding the graph data


function readArgumentFile(arguments)
	
	# argument length checking
	if length(arguments) != 1
		error("LALAExpected one argument: a Steiner Tree Problem - .stp - file")
	end

	# Script accepts the first argument as file input
	inputFile = arguments[1]
	
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
				# We multiply by may Int32 - an abreviation for M
				global adjMatrix = ones(nodes,nodes) * typemax(Int32)

				# Maybe change to sparse matrix? Depending on iteration of constraints
				# global adjMatrix = spzeros(nodes,nodes)

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

	println("Input: Nodes $(nodes), edges $(edges), terminals $(length(terminals))")
end
# readArgumentFile end
