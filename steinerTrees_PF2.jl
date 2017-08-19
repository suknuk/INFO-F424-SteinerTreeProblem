###########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Polzin and Daneshmand (2001). This (PF2)
# can be found in page 257 of Polzin and Daneshmand (2001).
###########################################################

function constraintsPF2()

	###########
	# Variables
	###########
	# Binary variable x to indicate if edge between nodes i and j was selected
	# Constraint 8
	@variable(m, x[1:nodes, 1:nodes], Bin)

	# Integer variables y to denote quantity of flow through edge i to j
	# y[i, j ,t]
	# yhat[i, j ,k, l]
	# Constraint 7 lowerbound included
	@variable(m, y[1:nodes, 1:nodes, 1:length(terminals)] >= 0, Int)
	@variable(m, yhat[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)] >= 0, Int)

	# z1 - Root node
	z1 = terminals[1]
	# R1 - all steiner nodes without the root node z1
	R1 = terminals[2:end]

	## k and l Lists pairs
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
	# Constraint 1
	for t = 1:length(terminals)
		zt = terminals[t]
		for i = 1:nodes
			incomingFlow = 0
			outgoingFlow = 0
			for j = 1:nodes
				if i != j && adjMatrix[i,j] != typemax(Int32)
					incomingFlow += y[j,i,t]
					outgoingFlow += y[i,j,t]
				end
			end

			if in(zt, R1)
				if i == zt
					@constraint(m, incomingFlow - outgoingFlow == 1)
				elseif i != z1 && i != zt
					@constraint(m, incomingFlow - outgoingFlow == 0)
				end
			end
		end
	end


	##############
	# Constraints 2,3,4,5
	for ti = 1:length(zlList)
		zk = zkList[ti]
		zl = zlList[ti]
		
		k = kList[ti]
		l = lList[ti]
		
		for i = 1:nodes
			incomingFlow2 = outgoingFlow2 = 0
			for j = 1:nodes
				if i != j && adjMatrix[i,j] != typemax(Int32)
					###
					# Constraint 2 flow
					incomingFlow2 += yhat[j,i,k,l]
					outgoingFlow2 += yhat[i,j,k,l]

					###
					# Constraint 3
					@constraint(m, yhat[i,j,k,l] <= y[i,j,k])

					###
					# Constraint 4
					@constraint(m, yhat[i,j,k,l] <= y[i,j,l])
					
					###
					# Constraint 5
					@constraint(m, y[i,j,k] + y[i,j,l] - yhat[i,j,k,l] <= x[i,j])
				end
			end
		
			###
			# Constraint 2
			if i == z1
				@constraint(m, incomingFlow2 - outgoingFlow2 >= -1)
			else
				@constraint(m, incomingFlow2 - outgoingFlow2 >= 0)
			end

		end
	end

	###
	# Constraint 6
	for i = 1:nodes
		if in(i, terminals)
			continue
		end
		outgoing = incoming = 0
		for j = 1:nodes
			if i != j && adjMatrix[i,j] != typemax(Int32)
				incoming += x[j,i]
				outgoing += x[i,j]
			end
		end
		@constraint(m, incoming - outgoing <= 0)
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
