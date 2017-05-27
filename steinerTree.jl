# Script accepts the first argument as file input
inputFile = ARGS[1]

println(inputFile)


# Problem size
nodes = 0
edges = 0
terminals = 0

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
			nodes = parse(Float64, "$(splitted[2])")
		
		# Check for Edges line
		elseif splitted[1] == "Edges"
			edges = parse(Float64, "$(splitted[2])")
		
		# Check for Edge point
		elseif splitted[1] == "E"
			# TODO

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
			terminals = parse(Float64, "$(splitted[2])")	
	
		# Check for Terminal node line
		elseif splitted[1] == "T"
			# TODO

		end
	end
end

close(f)

println("Nodes $(nodes), edges $(edges), terminals $(terminals)")

