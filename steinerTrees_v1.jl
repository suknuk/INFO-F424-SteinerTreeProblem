########################################################
# Raymond Lochner 2017
# Steiner Tree Problem formulation using the formulation
# proposed by Wong (1984). This (PF) can be found in
# page 244 of Polzin and Daneshmand (2001).
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
# Constraint 4
@variable(m, x[1:nodes, 1:nodes], Bin)

# Integer variable y to denote quantity of commodity t flowing through edge i to j
# y[i, j ,t]
@variable(m, y[1:nodes, 1:nodes, 1:length(terminals)], Int)

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
			end
			if i != z1 && i != zt
				@constraint(m, incomingFlow - outgoingFlow == 0)
			end
		end
	end
end

###
# Constraints 2 and 3
for t = 1:length(terminals)
	zt = terminals[t]
	if in(zt, R1)
		for i = 1:nodes
			for j = 1:nodes
				
				if adjMatrix[i,j] == typemax(Int32)
					continue
				end

				###
				# Constraint 2
				@constraint(m, x[i,j] >= y[i,j,t])
				
				###
				# Constraint 3
				@constraint(m, y[i,j,t] >= 0)
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
