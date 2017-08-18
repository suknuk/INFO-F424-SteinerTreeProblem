########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Liu (1990). This (P2T) can be found in
# page 245 of Polzin and Daneshmand (2001).
########################################################

function constraintsP2T()

	###########
	# Variables
	###########
	# Binary variable x to indicate if edge between nodes i and j was selected
	# Constraint 6
	@variable(m, x[1:nodes, 1:nodes], Bin)

	# Integer variables y to denote quantity of flow through edge i to j
	# y[i, j ,k, l]
	# Constraint 5 - included
	@variable(m, yhat[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)] >= 0, Int)
	@variable(m, yhat_left[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)] >= 0, Int)
	@variable(m, yhat_right[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)] >= 0, Int)

	# z1 - Root node
	z1 = terminals[1]
	# R1 - all steiner nodes without the root node z1
	R1 = terminals[2:end]

	## k and l Lists
	zlList = Int64[]
	zkList = Int64[]
	lList = Int64[]
	kList = Int64[]

	whichList = true

	for i = 1:length(R1)
		if whichList
			push!(zlList,R1[i])
			push!(lList,i+1)
		else
			push!(zkList,R1[i])
			push!(kList,i+1)
		end
		whichList = !whichList
	end

	if length(zlList) != length(zkList)
		push!(zkList,zkList[1])
		push!(kList,kList[1])
	end


	#############
	# Constraints
	#############

	###
	# Constraints 1 - 3
	for ti = 1:length(zlList)
		zk = zkList[ti]
		zl = zlList[ti]
		
		k = kList[ti]
		l = lList[ti]

		for i = 1:nodes
			incomingFlow1 = outgoingFlow1 = 0
			incomingFlow2 = outgoingFlow2 = 0
			incomingFlow3 = outgoingFlow3 = 0
			for j = 1:nodes
				if i != j && adjMatrix[i,j] != typemax(Int32)
					###
					# Constraint 1 flow
					incomingFlow1 += yhat[j,i,k,l]
					outgoingFlow1 += yhat[i,j,k,l]
					
					###
					# Constraint 2 flow
					incomingFlow2 += yhat[j,i,k,l] + yhat_left[j,i,k,l]
					outgoingFlow2 += yhat[i,j,k,l] + yhat_left[i,j,k,l]
					
					###
					# Constraint 3 flow
					incomingFlow3 += yhat[j,i,k,l] + yhat_right[j,i,k,l]
					outgoingFlow3 += yhat[i,j,k,l] + yhat_right[i,j,k,l]
				end
			end
		
			###
			# Constraint 1
			if i == z1
				@constraint(m, incomingFlow1 - outgoingFlow1 >= -1)
			else
				@constraint(m, incomingFlow1 - outgoingFlow1 >= 0)
			end

			###
			# Constraint 2
			if i == zk
				@constraint(m, incomingFlow2 - outgoingFlow2 == 1)
			elseif (i != z1) && (i != zk)
				@constraint(m, incomingFlow2 - outgoingFlow2 == 0)
			end
			
			###
			# Constraint 3
			if i == zl
				@constraint(m, incomingFlow3 - outgoingFlow3 == 1)
			elseif (i != z1) && (i != zl)
				@constraint(m, incomingFlow3 - outgoingFlow3 == 0)
			end
		end

		###
		# Constraint 4
		for i = 1:nodes
			for j = 1:nodes
				if (adjMatrix[i,j] == typemax(Int32)) || (i == j)
					continue
				end
				###
				# Constraint 4
				@constraint(m, yhat[i,j,k,l] + yhat_left[i,j,k,l] + yhat_right[i,j,k,l] <= x[i,j])
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
