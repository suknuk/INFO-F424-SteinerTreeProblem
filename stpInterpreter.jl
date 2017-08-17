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

function displayHelp()
	println("-f ; --file [path to .stp file]")
	println("--formulation [PF|P2T|PF2]	| default: PF")
	println("-v ; --verbose [true|false]	| default: false")
	println("-s ; --saveresult [filename]")
end

function readArgumentFile(arguments)
	
	hasInputFile = false
	global inputFile = ""

	global whichFormulation = "PF"

	global verbose = false
	global saveResult = false

	# argument length checking
	if length(arguments) == 0
		error("Expected arguments. Type -h or --help for help")
	else
		for i = 1:length(arguments)
			arg = arguments[i]
			if arg == "-f" || arg == "--file"
				global inputFile = arguments[i+1]
				hasInputFile = true
				i=i+1
			elseif arg == "--formulation"
				if arguments[i+1] == "PF"
					global whichFormulation = "PF"
				elseif arguments[i+1] == "P2T"
					global whichFormulation = "P2T"
				elseif arguments[i+1] == "PF2"
					global whichFormulation = "PF2"
				else
					println("Unknown formulation, using default formulation PF")
				end
			elseif arg == "-v" || arg == "--verbose"
				if arguments[i+1] == "false"
					global verbose = false
				elseif arguments[i+1] == "true"
					global verbose = true
				end
			elseif arg == "-s" || arg == "--saveresult"
				global saveResultFileName = arguments[i+1]
				global saveResult = true
			elseif arg == "-h" || arg == "--help"
				displayHelp()
				exit()
			end
		end
	end

	if !hasInputFile
		error("Expected input file. Type -h or --help for help")
	end

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
	
	if !verbose
		println("Input: Nodes $(nodes), edges $(edges), terminals $(length(terminals))")
	end
end
# readArgumentFile end
