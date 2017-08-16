########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Liu (1990). This (P2T) can be found in
# page 245 of Polzin and Daneshmand (2001).
########################################################


using JuMP

m = Model()

# Include file to read STP files
include("stpInterpreter.jl")

# pass over arguments to interpret the Steiner problem
readArgumentFile(ARGS)


###########
# Variables
###########
# Binary variable x to indicate if edge between nodes i and j was selected
# Constraint 6
@variable(m, x[1:nodes, 1:nodes], Bin)

# Integer variables y to denote quantity of flow through edge i to j
# y[i, j ,k, l]
@variable(m, yhat[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)], Int)
@variable(m, yhat_left[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)], Int)
@variable(m, yhat_right[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)], Int)

# z1 - Root node
z1 = terminals[1]
# R1 - all steiner nodes without the root node z1
R1 = terminals[2:end]

## test
#zk = terminals[2]
#zl = terminals[3]

chosenK = 0

#############
# Constraints
#############

hasConstraints = false

###
# Constraints 1 - 3
for k = 1:length(terminals)
	if hasConstraints
		continue
	end
	for l = 1:length(terminals)
		if k == l
			continue
		end
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)	
			hasConstraints = true
			chosenK = k
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
		end
	end
end

###
# Constraints 4 and 5
for k = 1:length(terminals)
	if k != chosenK
		continue
	end
	for l = 1:length(terminals)
		if k == l
			continue
		end
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)
			for i = 1:nodes
				for j = 1:nodes
					if (adjMatrix[i,j] == typemax(Int32)) || (i == j)
						continue
					end
					###
					# Constraint 4
					y_flow = yhat[i,j,k,l] + yhat_left[i,j,k,l] + yhat_right[i,j,k,l]
					@constraint(m, y_flow <= x[i,j])
					
					###
					# Constraint 5
					@constraint(m, yhat[i,j,k,l] >= 0)
					@constraint(m, yhat_left[i,j,k,l] >= 0)
					@constraint(m, yhat_right[i,j,k,l] >= 0)
				end
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
			total += x[i,j] * adjMatrix[i,j]
		end
	end
	return total
end

@objective(m, Min, objectiveFunction())


###################
# Solve and Display
###################

println("Number of constraints : ",MathProgBase.numconstr(m))

# Using tic(), toq() to measure the solving time
tic()
status = solve(m)
timeTaken = toq()


if status == :Infeasible
	error("No solution found!")
else
	println("Objective value: ", getobjectivevalue(m))
end

println("Solver took $timeTaken seconds to complete.")
