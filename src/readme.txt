1. Dependencies and installation
  a. Anaconda (python): https://www.anaconda.com/products/individual
  b. Julia: https://julialang.org/downloads/
  d. Add the Julia following Packages using Pkg.add("name"): Jump, Dates, Random, PyCall, PyPlot, JuMP, CPLEX
  e. install cplex
  c. add julia to path https://julialang.org/downloads/platform/

2. Tests Folder creation
  The user should create a tests folder.
  The test folders should be located in /src/Expes.
  Each test folder contains a subfolder that will contain the results and a config file
  a. The config file is a file of resolution parameters named parametres_expes.txt. These parameters are
  -  list of bibs to test
  -  connectivity module flag
  -  dominance inequalities flag
  -  covering-connectivity inequalities flag
  -  empty callback flag
  -  covering ineqsualities flag
  -  only on root separation flag
  -  frequency of separation
  -  exact separation
  -  solver name
  -  display resolution log flag
  -  time limit
  b. The results folder

2. Run the project
  a. Go to the root of the project folder "src"
  b. Run in julia the command line include("main.jl") at the root of the folder
  c. Enter the name of the tests folder that you want to solve.

3. Get results
  The results of resolution for a given test folder will be stored on the csv file Expes/test_folder_name/Results/results.csv.
  You can get the latex format of the csv table by using the julia notebook /src/ShowResults:
    using CSV
    using DataFrames
    df = DataFrame(CSV.File("Expes/test_folder_name/Results/results.csv"))
    show(stdout, MIME("text/latex"),df)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

2. Instances generation
    a. Description
    It is possible to generate several libraries  of instances. An instances library is a folder composed of a set of instances (the scenarios) and a contexte file.
    - The contexte file of is named contexte.dat and will be placed in the folder src/bibliotheques_instances/bib_name
    This file contains commun parameters of the library's instances:
    Nombre d'états (#T), de HAPS (#H), de positions envisageables pour le déploiement (#E), de types de communication (#C), d'unités (#U) et de bases (#B),
    Altitude de déploiement des HAPS (A), Nombre de relais par type de communication (R_1, R_2, ...), Types de communication de chaque unité (C_u),
    Portée de chaque unité par type de communication (P_u), Types de communication de chaque base (C_b), Positions des bases (x_b, y_b),
    Positions envisageables pour le déploiement d'un HAPS (x_e, y_e), Poids et puissance maximale de chacun des HAPS (W_h, P_h),
    Poids, puissance et portée de chacun des relais de type 1 (w_r, p_r, s_r), de type 2, etc.
    - The scenarios files (instances) is named scenario_i.dat, where i is the number of the scenario and will be placed in src/biblkiotheques_instances/bib_name/scenarios.
      A scenario file gives the positions of the units at each time slot.

  b. Generation of contexte and scenarios
    - The user should first create a bib folder src/bibliotheques_instances/bib_name. Give a significant name to the bib.
    - A contexte parameters file should be created in this bib. This file contain all contexte and scenarios parameters. An example is given in src/bibliotheques_instances/Test_Instance_Generation.
    - Go to src/generateur_instances and run in julia the command line include("generateur_contexte.jl")
    - Enter the name of the bib: bib_name
    - The contexte file src/bibliotheques_instances/bib_name/contexte.dat will be created.
    - The scenarios folder will be generated in src/bibliotheques_instances/bib_name/scenarios.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

3. Project files
  a. main.jl calls basic project functions for choosing the instances, conduct the context visualization and the scenario visualization,
    Solving the model and conduct the solution visualization.
  b. preprocessing_functions.jl contains essentially functions that are used for preprocessing of the model but also further functions that are used for creating the model and solving it
  c. model.jl is used to create the model, set different user callbacks, add optimality inequalities. Also, it calls the relaxation module in order to compute the relaxation objective value.
  d. relaxation.jl is used to solve the relaxation.
  f. result.jl contains functions to print the solution.
  g. visualisation.jl python visualisation functions
  h. utilitaires.jl used to display the contexte of the instance.
  i. structures.jl declares the structures used in the project.
  j. parser.jl contains input functions and function to read files.
  k. controles_saisies.jl used for verification of user input.
  l. parametres_solveurs.jl used to set solver parameters.
  m.generateur_instances/generateur_contexte.jl used to generate contexte and scenarios. 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

Annexes:
The theoretical materials behind this project is given in annexe.

Notes:
1. In this work, several variants of the same problem were developed. In this project the symmetric and communication via one base variant is considered.
