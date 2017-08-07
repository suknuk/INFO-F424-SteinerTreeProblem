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
# Constraint 3.4
@variable(m, x[1:nodes, 1:nodes], Bin)

# Integer variable yt to denote quantity of commodity t flowing through edge i to j
@variable(m, yt[1:nodes, 1:nodes], Int)

# z1 - Root node
z1 = terminals[1]
# R1 - all steiner nodes without the root node z1
R1 = terminals[2:end]

#############
# Constraints
#############

###
# Multicommodity flow constraints

###
# Constraint 3.1
for i = 1:nodes	
	incomingFlow = 0
	outgoingFlow = 0
	for j = 1:nodes
		if i != j
			incomingFlow += yt[j,i]
			outgoingFlow += yt[i,j]
		end
	end

	# First terminal node is the root node z1
	# But z1 is not in R1, so we do not add any constraints
	# It has a outgoing flow of length(terminals) - 1
	if i == z1
		# This constraint is achieved passively without this line
		#@constraint(m, outgoingFlow == length(terminals) - 1)

	else
		# Difference between incoming flow and outgoing flow
		# 0 if non-terminal node
		# 1 if terminal node - it 'consumes' one unit
		flowDifference = 0
		if in(i, terminals)
			flowDifference = 1
		end
		@constraint(m, incomingFlow - outgoingFlow == flowDifference)
	end
end

for i = 1:nodes
	for j = 1:nodes
		###
		# Constraint 3.2
		# Multiply the binary value in order to allow a flow unit
		# higher than one. This is necessary because the following
		#@constraint(m, x[i,j] >= yt[i,j])
		# will yield in wrong results in Julia
		@constraint(m, x[i,j]*typemax(Int16) >= yt[i,j])

		###
		# Constraint 3.3
		@constraint(m, yt[i,j] >= 0)
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