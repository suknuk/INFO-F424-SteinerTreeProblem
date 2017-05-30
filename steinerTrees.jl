using JuMP
using Cbc

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
#println("test1 : $(adjMatrix[:,:])")


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
# Keeping the similarity in the Binary Matrix
# Not sure to let it?
#=
for i = 1:nodes
	for j = 1:nodes
		@constraint(m, x[i,j] == x[j,i])
	end
end=#

###
# Every terminal has to be selected
# Formulation P_{UC}
# We could also do 'x[t,;] >= 1'
for t in terminals
	@constraint(m, sum(x[:,t]) >= 1)
end

###
# Multicommodity flow constraints
for i = 1:nodes
	for j = 1:nodes
		###
		# Constraint 3.1
		# TODO
		decision = 0
		if in(i, terminals)
			decision = 1
		end
		@constraint(m, yt[j,i] - yt[i,j] == decision)
		
		###
		# Constraint 3.2
		@constraint(m, x[i,j] >= yt[i,j])

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
	# Divide by two because we have a Adjacency Matrix -> maybe?
	# total = total / 2
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
	println("x = \n", getvalue(x))
end


