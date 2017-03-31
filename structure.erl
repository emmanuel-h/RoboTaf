-module(structure).
-export([start/0,salle_attente_voisins/1,robot_premier_tour/3,quelle_salle/9]).

% On commence par instancier les 9 salles et les 9 robots
start() ->
    Synchroniseur = self(),

    register(salle1,Salle1=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle2,Salle2=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle3,Salle3=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle4,Salle4=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle5,Salle5=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle6,Salle6=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle7,Salle7=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle8,Salle8=spawn(structure,salle_attente_voisins,[Synchroniseur])),
    register(salle9,Salle9=spawn(structure,salle_attente_voisins,[Synchroniseur])),

    QuelleSalle = spawn(structure,quelle_salle,[Salle1,Salle2,Salle3,Salle4,Salle5,Salle6,Salle7,Salle8,Salle9]),

    register(robot1,spawn(structure,robot_premier_tour,[1,salle1,Synchroniseur])),
    register(robot2,spawn(structure,robot_premier_tour,[2,salle2,Synchroniseur])),
    register(robot3,spawn(structure,robot_premier_tour,[3,salle3,Synchroniseur])),
    register(robot4,spawn(structure,robot_premier_tour,[4,salle4,Synchroniseur])),
    register(robot5,spawn(structure,robot_premier_tour,[5,salle5,Synchroniseur])),
    register(robot6,spawn(structure,robot_premier_tour,[6,salle6,Synchroniseur])),
    register(robot7,spawn(structure,robot_premier_tour,[7,salle7,Synchroniseur])),
    register(robot8,spawn(structure,robot_premier_tour,[8,salle8,Synchroniseur])),
    register(robot9,spawn(structure,robot_premier_tour,[9,salle9,Synchroniseur])),

    salle1 ! {quellesalle,QuelleSalle},
    salle2 ! {quellesalle,QuelleSalle},
    salle3 ! {quellesalle,QuelleSalle},
    salle4 ! {quellesalle,QuelleSalle},
    salle5 ! {quellesalle,QuelleSalle},
    salle6 ! {quellesalle,QuelleSalle},
    salle7 ! {quellesalle,QuelleSalle},
    salle8 ! {quellesalle,QuelleSalle},
    salle9 ! {quellesalle,QuelleSalle},

    synchroniseurs:synchroniseur(),
    synchroniseurs:syncAll(),
    ok.
	
% Renvoie un entier correspondant à la salle, ce qui permettra de déterminer par la suite dans quelle direction se trouve cette salle par rapport à l'actuelle
quelle_salle(Salle1,Salle2,Salle3,Salle4,Salle5,Salle6,Salle7,Salle8,Salle9) ->
    receive
	{quelleSalle,IdSalle,IdSender} ->
	    case IdSalle of
		Salle1 ->
		    IdSender ! 1;
		Salle2 ->
		    IdSender ! 2;
		Salle3 ->
		    IdSender ! 3;
		Salle4 ->
		    IdSender ! 4;
		Salle5 ->
		    IdSender ! 5;
		Salle6 ->
		    IdSender ! 6;
		Salle7 ->
		    IdSender ! 7;
		Salle8 ->
		    IdSender ! 8;
		Salle9 ->
		    IdSender ! 9
	    end
    end,
    quelle_salle(Salle1,Salle2,Salle3,Salle4,Salle5,Salle6,Salle7,Salle8,Salle9).
	     
	

% Permet aux robots de lock une salle tant qu'ils sont dedans
salle(PosPere,IdPere) ->
    receive
	{entrer,IdRobot} ->
	    IdRobot ! ok,
	    receive
		{pere,IdRobot} ->
		    IdRobot ! {pere,PosPere,IdPere},
		    receive
			libere -> salle(PosPere,IdPere)
		    end
	    end
    end.

% Suivant si on est le leader ou pas, on appelle la bonne fonction de construction d'arbre (seul le leader est actif au début)
salle_attente_leader(Voisins,Synchroniseur)->
    receive
	{quellesalle,QuelleSalle} ->
	    ok
    end,
    receive
	sync ->
	    receive
		{leader,neo,PosPere} ->
		    arbre:calculArbreLeader(Voisins),
		    synchroniseurs:activationSalles(),
		    IdPere=-1;
		{leader, nop} ->
		    IdPere=arbre:calculArbreGeneral(Voisins),
		    % On récupère notre numéro de salle
		    QuelleSalle!{quelleSalle,self(),self()},
		    receive
			NumMoi ->
			    ok
		    end,
		    % On récupère le numéro de salle de notre père
		    QuelleSalle!{quelleSalle,IdPere,self()},
		    receive
			NumPere ->
			    ok
		    end,
		    % Puis on calcule la direction dans laquelle se trouve notre père
		    PosPere=calcul_pos_pere(NumMoi,NumPere)
	    end
    end,
    Synchroniseur ! sync,
    receive
	sync ->
	    salle(PosPere,IdPere)
    end.

% Les salles commencent par attendre la liste de leurs voisins sous deux formes : Une liste des directions et une liste des processus
salle_attente_voisins(Synchroniseur)->
    receive
	{voisins,Voisins,IdRobot} ->
	    IdRobot ! {voisins,ok},
	    salle_attente_leader(Voisins,Synchroniseur)
	end.

% Le robot au premier tour fait un tour complet de la salle pour détecter les portes
robot_premier_tour(NbRobot,Salle,Synchroniseur) ->
    R = robotlab:get_robot(NbRobot),
    O=robotlab:mur(R),
    S=robotlab:mur(R),
    E=robotlab:mur(R),
    N=robotlab:mur(R),
    ListePortes=[O,S,E,N],
    % On calcule les processus
    ListeProcessusVoisins = salles_calcul_processus_voisins(Salle),
    Voisins = salles_calcul_voisins(ListePortes,ListeProcessusVoisins,[]),
    % On envoie à la salle la liste de ses voisins
    Salle ! {voisins,Voisins,self()},
    receive 
	{voisins,ok} -> ok
    end,
    % On lance le calcul des salles pour la construction de l'arbre
    salles_calcul_leader(ListePortes,Salle),
    % On attend que les salles aient fini de construire l'arbre
    Synchroniseur ! sync,
    receive
	sync ->
	    % On lance l'agorithme de déplacement des robots
	    Salle ! {entrer,self()},
	    receive
		ok ->
		    prochaine_salle:robot_prochaine_salle(Salle,ouest,R)
	    end
    end.

% Fonction pour calculer les salles voisines de la salle courante
salles_calcul_processus_voisins(Salle)->
    case Salle of
	salle1 ->
	    ListeProcessusVoisins = [salle0,salle4,salle2,salle0];
	salle2 ->
	    ListeProcessusVoisins = [salle1,salle5,salle3,salle0];
	salle3 ->
	    ListeProcessusVoisins = [salle2,salle6,salle0,salle0];
	salle4 ->
	    ListeProcessusVoisins = [salle0,salle7,salle5,salle1];
	salle5 ->
	    ListeProcessusVoisins = [salle4,salle8,salle6,salle2];
	salle6 ->
	    ListeProcessusVoisins = [salle5,salle9,salle0,salle3];
	salle7 ->
	    ListeProcessusVoisins = [salle0,salle0,salle8,salle4];
	salle8 ->
	    ListeProcessusVoisins = [salle7,salle0,salle9,salle5];
	salle9 ->
	    ListeProcessusVoisins = [salle8,salle0,salle0,salle6];
	_ ->
	    ListeProcessusVoisins = ["Salle non reconnue dans salles_calcul_processus_voisins"]
	end,
    ListeProcessusVoisins.


salles_calcul_voisins([],[],Voisins) ->
    Voisins;
% Si on a une salle avec une ouverture vers elle, on la rajoute dans la liste des processus voisins
salles_calcul_voisins([Porte|ListePortes],[Processus|ListeProcessus],Voisins) ->
    if
	(Porte == true) and (Processus /= salle0) ->
	    salles_calcul_voisins(ListePortes, ListeProcessus, [Processus|Voisins]);
	true ->
	    salles_calcul_voisins(ListePortes, ListeProcessus,Voisins)
    end.
    
% Suivant les emplacements des portes et de la salle, on détermine si la salle courante possède la sortie ou non, et donc si elle est le leader
salles_calcul_leader(ListePortes,Salle) ->
	case Salle of 
		salle1 -> Po = lists:nth(1,ListePortes),
			    Pn = lists:nth(4,ListePortes),
			    if 
				Po ->
				    Salle ! {leader,neo,ouest};
				Pn ->
				    Salle ! {leader,neo,nord};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle2 -> Pn = lists:nth(4,ListePortes),
			    if 
				Pn ->
					Salle ! {leader,neo,nord};
				true -> Salle ! {leader, nop}
			    end;
		salle3 -> Pe = lists:nth(3,ListePortes),
			    Pn = lists:nth(4,ListePortes),
			    if 
				Pe ->
				    Salle ! {leader,neo,est};
				Pn ->
				    Salle ! {leader,neo,nord};
			 
  			    true ->
				    Salle ! {leader, nop}
			    end;
		salle6 -> Pe = lists:nth(3,ListePortes),
			    if 
				Pe ->
				    Salle ! {leader,neo,est};
				true ->
				    Salle ! {leader, nop}
			    end;
		salle9 -> Pe = lists:nth(3,ListePortes),
			    Ps = lists:nth(2,ListePortes),
			    if 
				Pe ->
				    Salle ! {leader,neo,est};
				Ps ->
				    Salle ! {leader,neo,sud};
				true ->
				    Salle ! {leader, nop}
			    end;
		salle8 -> Ps = lists:nth(2,ListePortes),
			    if 
				Ps ->
					Salle ! {leader,neo,sud};
				true ->
				    Salle ! {leader, nop}
			    end;
		salle7 -> Po = lists:nth(1,ListePortes),
			    Ps = lists:nth(2,ListePortes),
			    if 
				Po ->
				    Salle ! {leader,neo,ouest};
				Ps ->
				    Salle ! {leader,neo,sud};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle4 -> Po = lists:nth(1,ListePortes),
			    if 
				Po ->
				    Salle ! {leader,neo,ouest};
				true ->
				    Salle ! {leader, nop}
			    end;
		salle5 -> Salle ! {leader,nop}
	end.

% Grâce aux numéros de deux salles, on peut déterminer la position de l'une par rapport à l'autre
calcul_pos_pere(NumMoi,NumPere) ->
    Res = NumPere - NumMoi,
    case Res of
	1 ->
	    est;
	-1 ->
	    ouest;
	3 ->
	    sud;
	-3 ->
	    nord
	end.
