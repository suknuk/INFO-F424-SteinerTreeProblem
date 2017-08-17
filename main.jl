#######################################
# Raymond Lochner 2017
# Solving the Steiner Tree Problem using
# various formulations
#
# This is the main entry point of the
# program
########################################

using JuMP

global m = Model()

include("stpInterpreter.jl")
readArgumentFile(ARGS)

# Binary variable x to indicate if edge between nodes i and j was selected
# This occurs in every formulation and only needs to be declared here
@variable(m, x[1:nodes, 1:nodes], Bin)

###
# Including the various formulations
include("steinerTrees_v1_test.jl")
include("steinerTrees_v3.jl")

###
# Adding constraints from the selected formulation
if whichFormulation == "PF"
	constraintsPF()
elseif whichFormulation == "P2T"
	error("Implement me")
elseif whichFormulation == "PF2"
	constraintsPF2()
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

nbConstraints = MathProgBase.numconstr(m)

if !verbose
	println("Number of constraints : ", nbConstraints)
end

# Using tic(), toq() to measure the solving time
tic()
status = solve(m)
timeTaken = floor(toq()*100) / 100

objVal = getobjectivevalue(m)

if status == :Infeasible
	#error("No solution found!")
	if !verbose
		println("Error: No solution found")
	end
else
	if !verbose
		println("Objective value: ", objVal )
	end
end

if !verbose
	println("Solver took $timeTaken seconds to complete.")
end

if saveResult
	f = open(saveResultFileName,"a")
	write(f, "$inputFile\t")
	write(f, "$whichFormulation\t")
	write(f, "$timeTaken\t")
	write(f, "$nbConstraints\t")	
	write(f, "$objVal\n")
	close(f)
end
