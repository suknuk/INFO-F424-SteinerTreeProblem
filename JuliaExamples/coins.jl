using JuMP
using Cbc

m = Model(solver=CbcSolver())

#Variables
@variable(m, pennies >= 0, Int)
@variable(m, nickels >= 0, Int)
@variable(m, dimes >= 0, Int)
@variable(m, quarters >= 0, Int)

#constraints
@constraint(m,1*pennies + 5*nickels + 10*dimes + 25*quarters == 99)

#objective to minimize
@objective(m,Min,2.5*pennies + 5*nickels + 2.268*dimes + 5.670*quarters)

#solve
status = solve(m)

println("Min weight: ", getobjectivevalue(m)," grams")
println("using: ")
println(round(getvalue(pennies))," pennies")
println(round(getvalue(nickels))," nickels")
println(round(getvalue(dimes))," dimes")
println(round(getvalue(quarters))," quarters")
