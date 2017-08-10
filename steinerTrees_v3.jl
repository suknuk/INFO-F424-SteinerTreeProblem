###########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Polzin and Daneshmand (2001). This (PF2)
# can be found in page 257 of Polzin and Daneshmand (2001).
###########################################################


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
# Constraint 8
@variable(m, x[1:nodes, 1:nodes], Bin)

# Integer variables y to denote quantity of flow through edge i to j
# y[i, j ,t]
# yhat[i, j ,k, l]
@variable(m, y[1:nodes, 1:nodes, 1:length(terminals)], Int)
@variable(m, yhat[1:nodes, 1:nodes, 1:length(terminals), 1:length(terminals)], Int)

# z1 - Root node
z1 = terminals[1]
# R1 - all steiner nodes without the root node z1
R1 = terminals[2:end]


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

###
# Constraint 2
for k = 1:length(terminals)
	for l = 1:length(terminals)
		if k == l
			continue
		end
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)
			for i = 1:nodes
				incomingFlow = 0
				outgoingFlow = 0
				for j = 1:nodes
					if (adjMatrix[i,j] != typemax(Int32)) && (i != j)
						incomingFlow += yhat[j,i,k,l]
						outgoingFlow += yhat[i,j,k,l]
					end
				end
				
				if i == z1
					@constraint(m, incomingFlow - outgoingFlow >= -1)
				else
					@constraint(m, incomingFlow - outgoingFlow >= 0)
				end
					
			end
		end
	end
end

###
# Constraints 3,4,5
for i = 1:nodes
	for j = 1:nodes
		if i == j || adjMatrix[i,j] == typemax(Int32)
			continue
		end

		for k = 1:length(terminals)
			for l = 1:length(terminals)
				if k == l 
					continue
				end
				zk = terminals[k]
				zl = terminals[l]
				if in(zk,R1) && in(zl,R1)
					
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


###
# Constraint 7
for i = 1:nodes
	for j = 1:nodes
		if i == j || adjMatrix[i,j] == typemax(Int32)
			continue
		end

		for k = 1:length(terminals)
			zk = terminals[k]
			for l = 1:length(terminals)
				if k == l
					continue
				end
				zl = terminals[l]
				if in(zk,R1) && in(zl,R1)
					@constraint(m, yhat[i,j,k,l] >= 0)
				end
			end
			if in(zk,R1)
				@constraint(m, y[i,j,k] >= 0)
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
