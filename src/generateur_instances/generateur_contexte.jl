########### Importations ###########

# Dépendances
using Dates
using Random

# Essentiels
include("controles_saisies.jl")


########## Générateur de contexte ##########

function generation_contexte()
    # Nettoyage de la console
    clear()
    println("Saisissez le nom du répertoire de la bibliothèque d'instances à générer: ")
    expefolder = readline()
    lignes = Vector{String}
    open("./../bibliotheques_instances/"*expefolder*"/contexte_parameters.txt") do fichier
        lignes = readlines(fichier)
    end
    println("\n========== Générateur de contexte ==========")
    contexte = ""
    doc = "" # Documentation de l'instance en cours de génération

    doc *= "========== Documentation =========="

    docTemp = "\n --> Nombre d'états : "
    # print(docTemp)
    nT = lignes[2]
    # println(nT)
    doc *= "\n" * docTemp * nT
    contexte *= "// Nombre d'états (#T), de HAPS (#H), de positions envisageables pour le déploiement (#E) de types de communication (#C), d'unités (#U) et de bases (#B)\n"
    contexte *= nT * ", "

    docTemp = "\n --> Nombre de HAPS : "
    # print(docTemp)
    nH = lignes[2]
    doc *= "\n" * docTemp * nH
    contexte *= nH * ", "
    nH = parse(Int, nH)

    println("\n    - Quadrillage (1000 * 1000)")
    # print("       --> Pas : ")
    pas = parse(Int, lignes[8])
    X = [0:pas:1000;]; Y = [0:pas:1000;]
    E = [(x,y) for x in X, y in Y]
    nE = length(E)
    docTemp = "\n --> Nombre de positions envisageables pour le déploiement d'un HAPS : $nE (quadrillage, pas : $pas)"
    # println(docTemp)
    doc *= "\n" * docTemp
    contexte *= string(nE) * ", "

    docTemp = "\n --> Nombre de types de communication : "
    # print(docTemp)
    nC = lignes[11]
    doc *= "\n" * docTemp * nC
    contexte *= nC * ", "
    nC = parse(Int, nC)

    docTemp = "\n --> Nombre d'unités : "
    # print(docTemp)
    nU = lignes[14]
    doc *= "\n" * docTemp * nU
    contexte *= nU * ", "
    nU = parse(Int, nU)

    docTemp = "\n --> Nombre de bases : "
    # print(docTemp)
    nB = lignes[17]
    doc *= "\n" * docTemp * nB
    contexte *= nB * "\n\n"
    nB = parse(Int, nB)

    contexte *= "// Altitude de déploiement des HAPS (A)\n"
    docTemp = "\n --> Altitude de déploiement des HAPS : "
    # print(docTemp)
    A = lignes[20]
    doc *= "\n" * docTemp * A
    contexte *= A * "\n\n"

    nRc = []
    contexte *= "// Nombre de relais par type de communication (R_1, R_2, ...)\n"
    a=parse(Int,lignes[23])
    b=parse(Int,lignes[24])
    for c in 1:nC
        docTemp = "\n --> Nombre de relais de type $c : "
        # print(docTemp)
        doc *= "\n" * docTemp
        val = rand(a:b)
        # println("$val")
        val = string(val)
        doc *= val
        if c != nC
            contexte *= val * ", "
        else
            contexte *= val * "\n"
        end
        push!(nRc, parse(Int, val))
    end
    contexte *= "\n"

    contexte *= "// Types de communication de chaque unité (C_u)\n"
    a=parse(Int,lignes[27])
    b=parse(Int,lignes[28])
    CU = Vector{Vector{Int}}(undef, nU)
    for u in 1:nU
        CU[u]=Int[]
        docTemp = "\n --> Types de communication de l'unité $u : "
        # print(docTemp)
        doc *= "\n" * docTemp
        nCu = rand([a:b;])
        Cu = shuffle(1:nC)[1:nCu]
        cpt = 1
        for Cu_i in Cu
            if cpt != nCu
                # print("$(Cu_i), ")
                doc *= string(Cu_i) * ", "
                contexte *= string(Cu_i) * ", "
                push!(CU[u], Cu_i)
            else
                # println("$(Cu_i)")
                doc *= string(Cu_i)
                contexte *= string(Cu_i) * "\n"
                push!(CU[u], Cu_i)
            end
            cpt += 1
        end
    end

# println(CU)
    contexte *= "\n"

    contexte *= "// Portée de chaque unité par type de communication (P_u)\n"

    a_portee=parse(Int,lignes[31])
    b_portee = parse(Int,lignes[32])
    for u in 1:nU
        docTemp = "      --> Portée unité (seuil) : "
        # print(docTemp)
        doc *= "\n" * docTemp
        cpt=1
        for c in CU[u]
            s = rand(a_portee:b_portee)
            # println("$s")
            s = string(s)
            doc *= s
            if cpt != length(CU[u])
                contexte *= s * ", "
            else
                contexte *= s * "\n"
            end
            cpt+=1
        end
    end

    contexte *= "\n"

    contexte *= "// Types de communication de chaque base (C_b)\n"
    nCb = nC
    com=""
    for i in 1:nC-1
        com=com*string(i)*", "
    end
    com=com*string(nC)* "\n"
    contexte *=com* "\n"

    contexte *= "// Positions des bases (x_b, y_b)\n"
    for base in 1:nB
        docTemp = "\n - Base $base : "
        # println(docTemp)
        doc *= "\n" * docTemp
        docTemp = "   --> x : "
        # print(docTemp)
        doc *= "\n" * docTemp
        x = lignes[35]
        doc *= x
        docTemp = "   --> y : "
        # print(docTemp)
        doc *= "\n" * docTemp
        y = lignes[36]
        doc *= y
        contexte *= x * ", " * y * "\n"
    end
    contexte *= "\n"

    contexte *= "// Positions envisageables pour le déploiement d'un HAPS (x_e, y_e)\n"
    cpt = 1
    for (x,y) in E
        docTemp = "\n - Position $cpt : "
        doc *= "\n" * docTemp
        docTemp = "   --> x : $x"
        doc *= "\n" * docTemp
        docTemp = "   --> y : $y"
        doc *= "\n" * docTemp
        contexte *= string(x) * ", " * string(y) * "\n"
        cpt += 1
    end
    contexte *= "\n"

    contexte *= "// Poids et puissance maximale de chacun des HAPS (W_h, P_h)\n"
    a_poids = parse(Int, lignes[39])
    b_poids = parse(Int, lignes[40])
    a_puissance = parse(Int, lignes[43])
    b_puissance = parse(Int, lignes[44])
    for h in 1:nH
        docTemp = "\n - HAPS $h : "
        # println(docTemp)
        doc *= "\n" * docTemp
        docTemp = "   --> Poids maximal : "
        # print(docTemp)
        doc *= "\n" * docTemp
        W = rand(a_poids:b_poids)
        # println("$W")
        W = string(W)
        doc *= W
        docTemp = "   --> Puissance maximale : "
        # print(docTemp)
        doc *= "\n" * docTemp
        P = rand(a_puissance:b_puissance)
        # println("$P")
        P = string(P)
        doc *= P
        contexte *= W * ", " * P * "\n"
    end
    contexte *= "\n"

    a_poids = parse(Int, lignes[47])
    b_poids = parse(Int, lignes[48])
    a_puissance = parse(Int, lignes[51])
    b_puissance = parse(Int, lignes[52])
    a_portee = parse(Int, lignes[55])
    b_portee = parse(Int, lignes[56])
    cpt = 1
    for c in 1:nC
        contexte *= "// Poids, puissance et portée de chacun des relais de type $c (w_r, p_r, s_r)\n"
        docTemp = "\n - Relais de type $c"
        # println(docTemp)
        doc *= "\n" * docTemp
        for r in 1:nRc[c]
            docTemp = "\n   - Relais $cpt : "
            # println(docTemp)
            doc *= "\n" * docTemp
            docTemp = "      --> Poids : "
            # print(docTemp)
            doc *= "\n" * docTemp
            w = rand(a_poids:b_poids)
            # println("$w")
            w = string(w)
            doc *= w
            docTemp = "      --> Puissance : "
            # print(docTemp)
            doc *= "\n" * docTemp
            p = rand(a_puissance:b_puissance)
            # println("$p")
            p = string(p)
            doc *= p
            docTemp = "      --> Portée (seuil) : "
            # print(docTemp)
            doc *= "\n" * docTemp
            s = rand(a_portee:b_portee)
            # println("$s")
            s = string(s)
            doc *= s
            cpt += 1
            contexte *= w * ", " * p * ", " * s * "\n"
        end
        if c != nC
            contexte *= "\n"
        end
    end
    doc *= "\n\n========== Documentation ==========\n"

    nom_dossier = string(today())*"_"*Dates.format(now(), "HH:MM:SS")
    # run(`mkdir contextes/$(nom_dossier)`)
    context_path="./../bibliotheques_instances/"*expefolder*"/contexte.dat"
    open("./../bibliotheques_instances/"*expefolder*"/contexte.dat", "w") do fichier
        write(fichier, contexte)
    end

    open("./../bibliotheques_instances/"*expefolder*"/documentation", "w") do fichier
        write(fichier, doc)
    end

    println("\n /!\\ Le contexte est disponible dans le dossier \"contextes/$(nom_dossier)/\" /!\\ ")
    println("\n========== Générateur de contexte ==========")

    println("\n========== Générateur de scénarios ==========")
    pas = parse(Float64, lignes[59])
    nb_scenarios = parse(Int, lignes[62])
    nom_dossier = "./../bibliotheques_instances/"*expefolder*"/scenarios"
    try
        run(`mkdir $(nom_dossier)`)
    catch
    end 

    nT, nU = lecture_depuis_fichier(context_path)
    for i in 1:nb_scenarios
        print("\n - Scénario $i : ")
        scenario = scenario_aleatoire(nT, nU, pas)
        println(" OK")
        ecrire_scenario(nom_dossier, scenario, i)
    end

    println("\n /!\\ Les différents scénarios sont disponibles dans le dossier \"scenarios/$(nom_dossier)/\" /!\\ ")
    println("\n========== Générateur de scénarios ==========")

end



function lecture_depuis_fichier(context_path)
    lignes = Vector{String}
    open(context_path) do fichier
        lignes = readlines(fichier)
    end

    nT, _, _, _, nU = parse.(Int, split(lignes[2], ","))
    return nT, nU
end

function scenario_aleatoire(nT, nU, pas)
    directions = [("O",1), ("NO",2), ("N",3), ("NE",4), ("E",5), ("SE",6), ("S",7), ("SO",8)] # Points cardinaux élémentaires
    correspondance = [(-pas, 0),  (-pas, pas), (0, pas), (pas, pas), (pas, 0), (pas, -pas), (0, -pas), (-pas, -pas)] # Correspondance entre direction et déplacement de l'unité sur le plan
    #liste_deplacements = Vector{Vector{Tuple}}(undef, sum(nUc))
    scenario = ""
    for u in 1:nU
        # Une unité
        scenario *= "// Déplacements de l'unité terrestre $u sur un horizon temporel (x_$u^t, y_$u^t) \n"
        liste_deplacements_unite = Vector{Tuple}(undef, nT)
        point = (rand(pas:pas:1000-pas), rand(pas:pas:1000-pas))
        liste_deplacements_unite[1] = point # Point de départ de l'unité (sur une position multiple de "pas")
        scenario *= "(" * string(point[1]) * "," * string(point[2]) * "), "
        for t in 2:nT
            # Un état particulier
            deplacement_valide = false
            nouvelle_coord = ()
            while !(deplacement_valide)
                direction = rand(directions)
                nouvelle_coord = liste_deplacements_unite[t-1] .+ correspondance[direction[2]]
                if (nouvelle_coord[1] >= pas && nouvelle_coord[1] <= 1000-pas) && (nouvelle_coord[2] >= pas && nouvelle_coord[2] <= 1000-pas) # On reste dans la boîte définie (avec une protection pour éviter d'être sur les bords)
                    deplacement_valide = true
                end
            end
            liste_deplacements_unite[t] = nouvelle_coord
            scenario *= "(" * string(nouvelle_coord[1]) * "," * string(nouvelle_coord[2])
            if t != nT
                scenario *= "), "
            end
        end
        scenario *= ")\n\n"
    end
    return scenario
end

function ecrire_scenario(nom_dossier, scenario, i)
    open("$(nom_dossier)/scenario_$i.dat", "w") do fichier
           write(fichier, scenario)
    end
end


generation_contexte()
