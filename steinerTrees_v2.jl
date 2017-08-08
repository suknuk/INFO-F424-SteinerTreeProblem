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
# Constraint 4.6
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


#############
# Constraints
#############

###
# Constraint 4.1
for k = 1:length(terminals)
	for l = 1:length(terminals)	
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)	
			for i = 1:nodes
				incomingFlow = 0
				outgoingFlow = 0
				for j = 1:nodes
					if i != j
						incomingFlow += yhat[j,i,k,l]
						outgoingFlow += yhat[i,j,k,l]
					end
				end
			
				if i == z1
					@constraint(m, incomingFlow - outgoingFlow >= -1)
				else
					@constraint(m, incomingFlow - outgoingFlow == 0)
				end
				
			end
		end
	end
end

###
# Constraint 4.2
for k = 1:length(terminals)
	for l = 1:length(terminals)	
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)
			for i = 1:nodes
				incomingFlow = 0
				outgoingFlow = 0
				for j = 1:nodes
					if i != j
						incomingFlow += yhat[j,i,k,l] + yhat_left[j,i,k,l]
						outgoingFlow += yhat[i,j,k,l] + yhat_left[i,j,k,l]
					end
				end
			
				if i == zk
					@constraint(m, incomingFlow - outgoingFlow == 1)
				elseif i != z1
					@constraint(m, incomingFlow - outgoingFlow == 0)
				end
			end
		end
	end
end

###
# Constraint 4.3
for k = 1:length(terminals)
	for l = 1:length(terminals)	
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)
			for i = 1:nodes
				incomingFlow = 0
				outgoingFlow = 0
				for j = 1:nodes
					if i != j
						incomingFlow += yhat[j,i,k,l] + yhat_right[j,i,k,l]
						outgoingFlow += yhat[i,j,k,l] + yhat_right[i,j,k,l]
					end
				end
			
				if i == zl
					@constraint(m, incomingFlow - outgoingFlow == 1)
				elseif i != z1
					@constraint(m, incomingFlow - outgoingFlow == 0)
				end
			end
		end
	end
end

#=
for t = 1:length(terminals)
	zt = terminals[t]
	for i = 1:nodes
		incomingFlow = 0
		outgoingFlow = 0
		for j = 1:nodes
			if i != j
				incomingFlow += y[j,i,t]
				outgoingFlow += y[i,j,t]
			end
		end

		if in(zt, R1)
			if i == zt
				@constraint(m, incomingFlow - outgoingFlow == 1)
			end
			if i != z1 && i != zt
				@constraint(m, incomingFlow - outgoingFlow == 0)
			end
		end
	end
end
=#

for k = 1:length(terminals)
	for l = 1:length(terminals)	
		zk = terminals[k]
		zl = terminals[l]
		if in(zk, R1) && in(zl, R1)
			for i = 1:nodes
				for j = 1:nodes
					###
					# Constraint 4.4
					y_flow = yhat[i,j,k,l] + yhat_left[i,j,k,l] + yhat_right[i,j,k,l]
					@constraint(m, y_flow <= x[i,j])
					
					###
					# Constraint 4.5
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
