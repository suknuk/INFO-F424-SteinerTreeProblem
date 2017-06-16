using JuMP

m = Model()

# Include file to read STP files
include("stpInterpreter.jl")

# argument length checking
if length(ARGS) != 1
	error("Expected one argument: a Steiner Tree Problem - .stp - file")
end

# pass over arguments to interpret the Steiner problem
readArgumentFile(ARGS)

println("Nodes $(nodes), edges $(edges), terminals $(length(terminals))")


###########
# Variables
###########
#Binary variable to indicate if edge between nodes i and j was selected
@variable(m, x[1:nodes, 1:nodes], Bin)

#Quantity of commodity t flowing through edge i to j
@variable(m, yt[1:nodes, 1:nodes], Int)


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

	# First terminal node is the root node
	# It has a outgoing flow of size(terminals) - 1
	if i == terminals[1]
		# This constraint is done achieved even without this line
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
		# higher than one
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

# Sum of Sum does not work like this?
#@objective(m, Min, sum( sum(adjMatrix[i,j] * x[i,j]  , j:1:nodes) , i=1:nodes))


###################
# Solve and Display
###################

status = solve(m)

if status == :Infeasible
	error("No solution found!")
else
	println("Objective value: ", getobjectivevalue(m))
	#println("x = \n", getvalue(x))
	#println("yt = \n", getvalue(yt))
end


