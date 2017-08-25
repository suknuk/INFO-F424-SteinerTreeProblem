# INFO-F424-SteinerTreeProblem
LP formulation in Julia to solve Steiner Tree Problem instances.

Run the program with:
```
julia main.jl --file [file]
```
which gives the objective value as the lowest spanning tree that covers all Steiner Points.

Options:
```
	-f ; --file        [path to .stp file]		(mandatory)
	     --formulation [PF|P2T|PF2]			| default: PF
	-m ; --model       [GLPK|Cbc|Gurobi|CPLEX]	| default: GLPK
	-v ; --verbose     [true|false]			| default: false
	-s ; --saveresult  [filename]
```
