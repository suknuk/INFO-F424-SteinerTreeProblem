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


####################################
# Including the various formulations
####################################
include("steinerTrees_PF.jl")
include("steinerTrees_P2T.jl")
include("steinerTrees_PF2.jl")

##################################################
# Adding constraints from the selected formulation
##################################################
if whichFormulation == "PF"
	constraintsPF()
elseif whichFormulation == "P2T"
	constraintsP2T()
elseif whichFormulation == "PF2"
	constraintsPF2()
else
	error("Formulation $whichFormulation not implemented")
end


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
