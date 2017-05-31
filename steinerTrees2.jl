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

#Quantity of commodity t flowing from z1 to vs
@variable(m, yhat[1:nodes, 1:nodes], Int)

#Quantity of commodity t flowing from vs to vk
@variable(m, yhatl[1:nodes, 1:nodes], Int)

#Quantity of commodity t flowing from vs to vl
@variable(m, yhatr[1:nodes, 1:nodes], Int)


#############
# Constraints
#############

###
# Two-terminal flow constraints

for i = 1:nodes
	# Initialising the incoming and outgoing flows
	incomingFlowYHat = 0
	outgoingFlowYHat = 0

	incomingFlowYHatL = 0
	outgoingFlowYHatL = 0

	incomingFlowYHatR = 0
	outgoingFlowYHatR = 0
	
	for j = 1:nodes
		if i != j
			incomingFlowYHat += yhat[j,i]
			outgoingFlowYHat += yhat[i,j]
			
			incomingFlowYHatL += yhatl[j,i]
			outgoingFlowYHatL += yhatl[i,j]
			
			incomingFlowYHatR += yhatr[j,i]
			outgoingFlowYHatR += yhatr[i,j]
		end
	end

	###
	# Constraint 4.1
	flowDifference41 = 0
	if i == terminals[1]
		flowDifference41 = -1
	end
	@constraint(m, incomingFlowYHat - outgoingFlowYHat == flowDifference41)


	###
	# Constraint 4.2	
	flowDifference42 = 0
	if i == terminals[2]
		flowDifference42 = 1
	end
	sumL42 = incomingFlowYHat + incomingFlowYHatL
	sumR42 = outgoingFlowYHat + outgoingFlowYHatL
	@constraint(m, sumL42 - sumR42 == flowDifference42)


	###
	# Constraint 4.3	
	flowDifference43 = 0
	if i == terminals[3]
		flowDifference43 = 1
	end
	sumL43 = incomingFlowYHat + incomingFlowYHatR
	sumR43 = outgoingFlowYHat + outgoingFlowYHatR
	@constraint(m, sumL43 - sumR43 == flowDifference43)
end


for i = 1:nodes
	for j = 1:nodes
		###
		# Constraint 4.4
		# Multiply the binary value in order to allow a flow unit
		# higher than one
		@constraint(m, yhat[i,j] + yhatl[i,j] + yhatr[i,j] <= x[i,j]*typemax(Int16))

		###
		# Constraint 4.5
		@constraint(m, yhat[i,j] >= 0)
		@constraint(m, yhatl[i,j] >= 0)
		@constraint(m, yhatr[i,j] >= 0)
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


