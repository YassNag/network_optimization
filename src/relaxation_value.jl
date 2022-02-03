function relaxation_value(relaxed_modele, instance)
    println("solving the relaxation")
    set_optimizer(relaxed_modele, CPLEX.Optimizer)
    relax_integrality(relaxed_modele)
    # # #disable cplex presolve options
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_PROBE", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_HEURFREQ", -1) #Turn off node heuristics
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_RINSHEUR", -1)  #Manual says, this is turned off if HEURFREQ is -1
    # # set_optimizer_attribute(modele, "CPX_PARAM_CUTPASS", -1) # Make no passes attempting to generate cuts.
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_PREIND", 0) # Turn off presolve completely
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_AGGIND", 0) # Do NOT use any aggregator ideas
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_RELAXPREIND", 0) # Do NOT APPLY LP presolve routines to root node relaxation
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_PREPASS", 0) # dO NOt apply any presolve passes.
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_REPEATPRESOLVE", 0) # Do NOT repeat presolve after root node is otherwise processed.
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_BNDSTRENIND", 0) # Do not apply bound strengthening
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_COEREDIND", 0) # Disable coefficient reduction in presolving
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_CUTSFACTOR", 1) # 1 means, total number of constraints
    # #should be same as original set…thus, no NEW cuts will be generated.
    #
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_REDUCE", 0) # Do not apply any primal or dual reductions
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_MIPSEARCH", 1) # 1 means conventional
    # # set_optimizer_attribute(modele, "CPX_PARAM_SUBMIPNODELIM", 0) # No submip nodes
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_MIPEMPHASIS", 3) # Do not waste time attempting to find feasible solutions
    #
    # #disable cplex cuts
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_CLIQUES", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_BQPCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_COVERS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_DISJCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_FLOWCOVERS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_FLOWPATHS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_FRACCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_GUBCOVERS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_ZEROHALFCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_MIRCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_IMPLBD", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_MIRCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_MCFCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_RLTCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_ZEROHALFCUTS", -1)
    # set_optimizer_attribute(relaxed_modele, "CPX_PARAM_LANDPCUTS", -1)

    if separation_exacte==false && separation_heuristique==false
        optimize!(relaxed_modele)
        z2 = objective_value(relaxed_modele)
        lecture_resultats_modele(instance, E1, E2, relaxed_modele, Vertices, Arcs, Ebis, true)
        println("relxation solution: $z2")
    end
    if separation_exacte==true
        z2=exact_cutting_plane(relaxed_modele, instance)
    end
    if separation_heuristique==true
        z2=heuristic_cutting_plane(relaxed_modele, instance)
    end
    return z2
end


function find_heuristic_cuts(x_vals, y_vals, pool, instance)
    res=[]
    for h in 1:nH
        vmax=0
        max=0
        for v in Vertices[2:size(Vertices,1)]
            if x_vals[h,Ebis[v-1]] >= max
                vmax=v
                max= x_vals[h,Ebis[v-1]]
            end
        end
        v=vmax

        Rw=[i for i in 1:nR]
        Rp=Rw
        sort!(Rw, by = r -> y_vals[r,Ebis[v-1]]*p[r], rev=true)
        sort!(Rp, by = r -> y_vals[r,Ebis[v-1]]*w[r], rev=true)

        #Power cover inequalities
        weight=0
        Rcover=Int[]
        cpt=1
        while weight <= P[h] && cpt <= nR
            weight+=p[Rp[cpt]]
            push!(Rcover, Rp[cpt])
            # println(weight)
            cpt+=1
        end
        if  weight > P[h] && Rcover!=[]
            cut_val=sum(y_vals[r,Ebis[v-1]] for r in Rcover)
            Rhs=length(Rcover)-x_vals[h,Ebis[v-1]]
            # println("cut power value: $cut_val, Rhs: $Rhs")
            if cut_val > Rhs+epsilone && (h,v,Rcover) ∉ pool
                    # nb_const+=1
                    println("Power : $h, $v, $Rcover, $cut_val, $Rhs")
                    push!(pool,(h,v,Rcover))
                    push!(res,(h,v,Rcover))
                    # println(pool)
            end
        end

        #weight cover inequalities
        weight=0
        Rcover=Int[]
        Rr=[[r for r in R[c]] for c in 1:nC]
        for c in 1:nC
            sort!(Rr[c], by = r -> y_vals[r,Ebis[v-1]]/w[r], rev=true)
        end
        cpt=1
        while weight <= W[h] && cpt <= nR
            weight+=w[Rw[cpt]]
            push!(Rcover, Rw[cpt])
            # println(weight)
            cpt+=1
        end
        # println("Cover : $Rcover")
        # println(weight, W[h])
        if  weight > W[h] && Rcover!=[]
            cut_val=sum(y_vals[r,Ebis[v-1]] for r in Rcover)
            Rhs=length(Rcover)-x_vals[h,Ebis[v-1]]
            # println("cut power value: $cut_val, Rhs: $Rhs")
            if cut_val > Rhs + epsilone && (h,v,Rcover) ∉ pool
                println("Weight : $h, $v, $Rcover, $cut_val, $Rhs")
                # println("nb_const: $nb_const")
                push!(pool,(h,v,Rcover))
                push!(res,(h,v,Rcover))
            end
        end
    end
    return res
end

function find_exact_cuts(x_vals, y_vals, pool, instance)
    res=[]
    for h in 1:nH
        ##Power capacity separation
        model_sep = Model()
        #Variables
        @variables(model_sep, begin
            beta[Vertices[2:size(Vertices,1)]], Bin
            gamma[1:nR], Bin
            delta[Vertices[2:size(Vertices,1)], 1:nR], Bin
            end)
        #Constraintes
        @constraint(model_sep, sum(beta[v] for v in Vertices[2:size(Vertices,1)]) ==1)
        @constraint(model_sep, sum(p[r]*gamma[r] for r in 1:nR ) >= sum((P[h]+1)*beta[v] for v in Vertices[2:size(Vertices,1)]))
        for r in 1:nR
            for v in Vertices[2:size(Vertices,1)]
                @constraint(model_sep, beta[v] + gamma[r] -1 <= delta[v,r])
            end
        end
        #Objective
        @objective(model_sep, Min, sum((1-y_vals[r,Ebis[v-1]])*delta[v,r] for v in Vertices[2:size(Vertices,1)] for r in 1:nR)-
            sum(x_vals[h,Ebis[v-1]]*beta[v] for v in Vertices[2:size(Vertices,1)]))
        #Optimize
        set_optimizer(model_sep, CPLEX.Optimizer)
        set_optimizer_attribute(model_sep, "CPX_PARAM_SCRIND", 0)
        optimize!(model_sep)
        z_sep = objective_value(model_sep)
        # println("objective sep: $z_sep")
        println("z_sep: $z_sep")
        if z_sep<0-epsilone
            println("violated power constraint : $z_sep")
            beta_vals = round.(Int, value.(model_sep[:beta]))
            gamma_vals = round.(Int, value.(model_sep[:gamma]))

            v=0
            for v1 in Vertices[2:size(Vertices,1)]
                if beta_vals[v1]>epsilone
                    v=v1
                    break
                end
            end
            #FInd the cover
            RCover=[]
            for r in 1:nR
                if gamma_vals[r]>epsilone
                    push!(RCover,r)
                end
            end

            if (h,v,RCover) ∉ pool
                println("power : $h, $v, $RCover, $z_sep")
                push!(pool,(h,v,RCover))
                push!(res,(h,v,RCover))
            end

        end

        ## Weight capacity separation
        model_sep = Model()
        #Variables
        @variables(model_sep, begin
            beta[Vertices[2:size(Vertices,1)]], Bin
            gamma[1:nR], Bin
            delta[Vertices[2:size(Vertices,1)], 1:nR], Bin
            end)
        #Constraintes
        @constraint(model_sep, sum(beta[v] for v in Vertices[2:size(Vertices,1)]) ==1)
        @constraint(model_sep, sum(w[r]*gamma[r] for r in 1:nR ) >= sum((W[h]+1)*beta[v] for v in Vertices[2:size(Vertices,1)]))
        for r in 1:nR
            for v in Vertices[2:size(Vertices,1)]
                @constraint(model_sep, beta[v] + gamma[r] -1 <= delta[v,r])
            end
        end
        #Objective
        @objective(model_sep, Min, sum((1-y_vals[r,Ebis[v-1]])*delta[v,r] for v in Vertices[2:size(Vertices,1)] for r in 1:nR)-
            sum(x_vals[h,Ebis[v-1]]*beta[v] for v in Vertices[2:size(Vertices,1)]))
        #Optimize
        set_optimizer(model_sep, CPLEX.Optimizer)
        set_optimizer_attribute(model_sep, "CPX_PARAM_SCRIND", 0)
        optimize!(model_sep)
        z_sep = objective_value(model_sep)
        println("z_sep: $z_sep")
        if z_sep<0-epsilone
            println("violated weight constraint : $z_sep")
            beta_vals = round.(Int, value.(model_sep[:beta]))
            gamma_vals = round.(Int, value.(model_sep[:gamma]))
            #Find v
            v=0
            for v1 in Vertices[2:size(Vertices,1)]
                if beta_vals[v1]>epsilone
                    v=v1
                    break
                end
            end
            #Find the cover
            RCover=[]
            for r in 1:nR
                if gamma_vals[r]>epsilone
                    push!(RCover,r)
                end
            end
            if (h,v,RCover) ∉ pool
                println("weight : $h, $v, $RCover, $z_sep")
                push!(pool,(h,v,RCover))
                push!(res,(h,v,RCover))
            end
        end
    end
    return res # toutes les contraintes violée, contrainte violée localement
end

function exact_cutting_plane(relaxed_modele, instance)
    is_over = false
    pool=[]
    y = relaxed_modele[:y]
    x = relaxed_modele[:x]
    while !is_over
        optimize!(relaxed_modele)
        x_vals = value.(relaxed_modele[:x])
        y_vals = value.(relaxed_modele[:y])
        res = find_exact_cuts(x_vals, y_vals, pool, instance)
        if length(res)==0
            is_over = true
        else
            for p in res
              @constraint(relaxed_modele, sum(y[r,Ebis[p[2]-1]] for r in p[3]) <=  length(p[3])-x[p[1],Ebis[p[2]-1]])
            end
        end
    end
   z2 = objective_value(relaxed_modele)
   lecture_resultats_modele(instance, E1, E2, relaxed_modele, Vertices, Arcs, Ebis, true)
   println("relxation solution: $z2")
   return z2
end


function heuristic_cutting_plane(relaxed_modele, instance)
    is_over = false
    pool=[]
    y = relaxed_modele[:y]
    x = relaxed_modele[:x]
    while !is_over
        optimize!(relaxed_modele)
        x_vals = value.(relaxed_modele[:x])
        y_vals = value.(relaxed_modele[:y])
        res = find_heuristic_cuts(x_vals, y_vals, pool, instance)
        if length(res)==0
            is_over = true
        else
            for p in res
              @constraint(relaxed_modele, sum(y[r,Ebis[p[2]-1]] for r in p[3]) <=  length(p[3])-x[p[1],Ebis[p[2]-1]])
            end
        end
    end
   z2 = objective_value(relaxed_modele)
   lecture_resultats_modele(instance, E1, E2, relaxed_modele, Vertices, Arcs, Ebis, true)
   println("relxation solution: $z2")
   return z2
end
