########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Wong (1984). This (PF) can be found in
# page 244 of Polzin and Daneshmand (2001).
########################################################


function constraintsPF()

	###########
	# Variables
	###########

	# Binary variable x to indicate if edge between nodes i and j was selected
	# Constraint 4
	@variable(m, x[1:nodes, 1:nodes], Bin)
	
	# Integer variable y to denote quantity of commodity t flowing through edge i to j
	# y[i, j ,t]
	# Constraint 3 included with lower/upper bound
	@variable(m, y[1:nodes, 1:nodes, 1:length(terminals)], Int, lowerbound=0, upperbound = 1)

	# z1 - Root node
	z1 = terminals[1]
	# R1 - all steiner nodes without the root node z1
	R1 = terminals[2:end]


	#############
	# Constraints
	#############

	###
	# Constraint 1,2
	for t = 1:length(terminals)
		zt = terminals[t]
		if in(zt, R1)
			for i = 1:nodes
				incomingFlow = 0
				outgoingFlow = 0
				for j = 1:nodes
					if adjMatrix[i,j] == typemax(Int32) || i == j
						continue
					end

					incomingFlow += y[j,i,t]
					outgoingFlow += y[i,j,t]
				
					###
					# Constraint 2
					@constraint(m, x[i,j] >= y[i,j,t])
				
				end
				
				###
				# Constraint 1
				if i == zt
					@constraint(m, incomingFlow - outgoingFlow == 1)
				end
				if i != z1 && i != zt
					@constraint(m, incomingFlow - outgoingFlow == 0)
				end
				
			end
		end
	end

	###########
	# Objective
	###########

	# Take the sum of each chosen weight
	function objectiveFunction()
		total = 0
		for i = 1:nodes	
			for j = 1:nodes
				if i != j
					total += x[i,j] * adjMatrix[i,j]
				end
			end
		end
		return total
	end

	@objective(m, Min, objectiveFunction())
end
