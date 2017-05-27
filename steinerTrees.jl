# Include file to read STP files
include("stpInterpreter.jl")

# pass over arguments to interpret the Steiner problem
readArgumentFile(ARGS)


println("Nodes $(nodes), edges $(edges), terminals $(length(terminals))")
