-module(structure).
-export([arbre_init/0,arbre_vide/1,arbre_ajouter_fils/2,arbre_gen/3]).

start() ->
	register(salle1,spawn(demo,salle,[])),
	register(salle2,spawn(demo,salle,[])),
	register(salle3,spawn(demo,salle,[])),
	register(salle4,spawn(demo,salle,[])),
	register(salle5,spawn(demo,salle,[])),
	register(salle6,spawn(demo,salle,[])),
	register(salle7,spawn(demo,salle,[])),
	register(salle8,spawn(demo,salle,[])),
	register(salle9,spawn(demo,salle,[])),
	register(robot1,spawn(demo,robot_premier_tour,[self()])),
	register(robot2,spawn(demo,robot_premier_tour,[self()])),
	register(robot3,spawn(demo,robot_premier_tour,[self()])),
	register(robot4,spawn(demo,robot_premier_tour,[self()])),
	register(robot5,spawn(demo,robot_premier_tour,[self()])),
	register(robot6,spawn(demo,robot_premier_tour,[self()])),
	register(robot7,spawn(demo,robot_premier_tour,[self()])),
	register(robot8,spawn(demo,robot_premier_tour,[self()])),
	register(robot9,spawn(demo,robot_premier_tour,[self()])),

	receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,
    receive
		fin -> ok
    end,

    salle1!fin,
    salle2!fin,
    salle3!fin,
    salle4!fin,
    salle5!fin,
    salle6!fin,
    salle7!fin,
    salle8!fin,
    salle9!fin,
    ok.
    
    
salle() ->
    receive
	{IdRobot,demande} -> IdRobot!ok,
			     receive
				 libere -> salle()
			     end;
	fin -> ok
    end.

% Thibault
% Fonction pour que le salles communiquent entre elles
salle_com() ->
    receive
	{IdSalle,pere} -> IdSalle!{self(),fils},
			  receive
			      {IdSalle,pere} -> IdSalle!refus
			  end
    end.


robot_premier_tour(IdRobot) ->
	ok.

salles_calcul_leader() ->
	ok.
	
% Thibault
% Initialisation d'un arbre vide
% {Id du noeud, Id du pere, tableau d'atomes qui sont les fils}
arbre_init() ->
    {null,null,[]}.

% Thibault
% Constructeur d'arbre
arbre_gen(IdNoeud,Pere,Fils) ->
    {IdNoeud,Pere,Fils}.

% Thibault
% Test si l'arbre est vide
arbre_vide({null,null,[]}) ->
    true;
arbre_vide({_,_,[]}) ->
    false.

% Thibault
% Ajout fils à l'arbre
arbre_ajouter_fils({IdNoeud,Pere,Fils},E) ->
    A = arbre_gen(E,IdNoeud,[]),
    {IdNoeud,Pere,[A|Fils]}.

% Thibault
salles_get_voisins() ->
    ok.

% Thibault
% Ajouter les salles voisines à la strucuture d'arbre
salles_ajouter_voisins(_,[]) ->
    ok;
salles_ajouter_voisins({IdNoeud,Pere,Fils},[H|T]) ->
    H!{self(),pere},
    receive
	{IdFils,fils} -> arbre_ajouter_fils({IdNoeud,Pere,Fils},IdFils)
    end,
    salles_ajouter_voisins(T).

% Thibault
% propoage la construction de l'arbre sur les voisins
appliquer_constructions_voisins([]) ->
    ok;
appliquer_constructions_voisins([H|T]) ->
    salles_constructions_voisins(H).

% Thibault
% fonction de construction des voisins
salles_constructions_voisins({IdNoeud,Pere,Fils}) ->
    Voisins = salles_get_voisines(IdNoeud),
    arbre_ajouter_voisins(Racine,Voisins),
    salles_constructions_voisins(Voisins),
    appliquer_constructions_voisins(Voisins).

% Thibault
% Fonction de construction de l'arbre inital
salles_construction_arbre(SalleLeader) ->
    Racine = arbre_gen(SalleLeader,null,[]),
    salles_constructions_voisins(Racine).
    
    

	
robot_prochaine_salle(Pid) ->
	ok.
