#   The code below acknowledges the contribution from https://github.com/jump-dev/JuMP.jl/blob/master/examples/sudoku.jl.
#   I changed the code to allow the input to be matrix directly.


using JuMP, GLPK

#   solve sudoku given initial input is filepath
function solve_sudoku(filepath)
    initial_grid = zeros(Int, 9, 9)
    open(filepath, "r") do fp
        for row in 1:9
            line = readline(fp)
            initial_grid[row, :] .= parse.(Int, split(line, "  "))
        end
    end

    model = Model(GLPK.Optimizer)

    @variable(model, x[1:9, 1:9, 1:9], Bin)

    @constraints(model, begin
        # Constraint 1 - Only one value appears in each cell
        cell[i in 1:9, j in 1:9], sum(x[i, j, :]) == 1
        # Constraint 2 - Each value appears in each row once only
        row[i in 1:9, k in 1:9], sum(x[i, :, k]) == 1
        # Constraint 3 - Each value appears in each column once only
        col[j in 1:9, k in 1:9], sum(x[:, j, k]) == 1
        # Constraint 4 - Each value appears in each 3x3 subgrid once only
        subgrid[i=1:3:7, j=1:3:7, val=1:9], sum(x[i:i + 2, j:j + 2, val]) == 1
    end)

    # Initial solution
    for row in 1:9, col in 1:9
        if initial_grid[row, col] != 0
            @constraint(model, x[row, col, initial_grid[row, col]] == 1)
        end
    end

    # Solve it
    JuMP.optimize!(model)

    term_status = JuMP.termination_status(model)
    primal_status = JuMP.primal_status(model)
    is_optimal = term_status == MOI.OPTIMAL

    # Check solution
    if is_optimal
        mip_solution = JuMP.value.(x)
        sol = zeros(Int, 9, 9)
        for row in 1:9, col in 1:9, val in 1:9
            if mip_solution[row, col, val] >= 0.9
                sol[row, col] = val
            end
        end
        return sol
    else
        error("The solver did not find an optimal solution.")
    end
end


#   solve sudoku given initial input is matrix
function solve_sudoku(init_sudoku)
    initial_grid = init_sudoku

    model = Model(GLPK.Optimizer)

    @variable(model, x[1:9, 1:9, 1:9], Bin)

    @constraints(model, begin
        # Constraint 1 - Only one value appears in each cell
        cell[i in 1:9, j in 1:9], sum(x[i, j, :]) == 1
        # Constraint 2 - Each value appears in each row once only
        row[i in 1:9, k in 1:9], sum(x[i, :, k]) == 1
        # Constraint 3 - Each value appears in each column once only
        col[j in 1:9, k in 1:9], sum(x[:, j, k]) == 1
        # Constraint 4 - Each value appears in each 3x3 subgrid once only
        subgrid[i=1:3:7, j=1:3:7, val=1:9], sum(x[i:i + 2, j:j + 2, val]) == 1
    end)

    # Initial solution
    for row in 1:9, col in 1:9
        if initial_grid[row, col] != 0
            @constraint(model, x[row, col, initial_grid[row, col]] == 1)
        end
    end

    # Solve it
    JuMP.optimize!(model)

    term_status = JuMP.termination_status(model)
    primal_status = JuMP.primal_status(model)
    is_optimal = term_status == MOI.OPTIMAL

    # Check solution
    if is_optimal
        mip_solution = JuMP.value.(x)
        sol = zeros(Int, 9, 9)
        for row in 1:9, col in 1:9, val in 1:9
            if mip_solution[row, col, val] >= 0.9
                sol[row, col] = val
            end
        end
        return sol
    else
        error("The solver did not find an optimal solution.")
    end
end



function print_sudoku_solution(solution)
    println("Solution:")
    println("|-----------------------|")
    for row in 1:9
        print("| ")
        for col in 1:9
            print(solution[row, col], " ")
            if col % 3 == 0 && col < 9
                print("| ")
            end
        end
        println("|")
        if row % 3 == 0
            println("|-----------------------|")
        end
    end
end



#   Now let's play
#   I prefer use matrix as initial input
#   Each 0 represents the blank to fill
init_sol = [ 6 0 0 0 3 1 9 0 0;
             8 0 0 0 0 0 0 0 0;
             0 0 4 8 0 7 0 0 0;
             0 0 0 0 8 0 0 0 0;
             4 5 0 0 6 0 3 0 0;
             9 8 0 0 0 0 5 6 0;
             0 0 0 0 0 0 0 0 5;
             1 0 0 4 9 6 0 3 0;
             0 0 0 0 0 0 0 0 0]

sdk_solution=solve_sudoku(init_sol)

# if take the initial grid as a CSV file at `filepath`
solution=solve_sudoku(joinpath(@__DIR__, "sudoku.csv"))

print_sudoku_solution(sdk_solution)
