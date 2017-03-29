-module(structure).
-export([start/0,salle/0,salle_attente_voisins/0,robot_premier_tour/4,salles_calcul_leader/2,salles_calcul_processus_voisins/1,salles_calcul_voisins/3,salle_attente_leader/2]).

% On commence par instancier les 9 salles et les 9 robots
start() ->
    Synchroniseur = self(),
    register(salle1,spawn(structure,salle_attente_voisins,[])),
    register(salle2,spawn(structure,salle_attente_voisins,[])),
    register(salle3,spawn(structure,salle_attente_voisins,[])),
    register(salle4,spawn(structure,salle_attente_voisins,[])),
    register(salle5,spawn(structure,salle_attente_voisins,[])),
    register(salle6,spawn(structure,salle_attente_voisins,[])),
    register(salle7,spawn(structure,salle_attente_voisins,[])),
    register(salle8,spawn(structure,salle_attente_voisins,[])),
    register(salle9,spawn(structure,salle_attente_voisins,[])),
    register(robot1,spawn(structure,robot_premier_tour,[self(),1,salle1,Synchroniseur])),
    register(robot2,spawn(structure,robot_premier_tour,[self(),2,salle2,Synchroniseur])),
    register(robot3,spawn(structure,robot_premier_tour,[self(),3,salle3,Synchroniseur])),
    register(robot4,spawn(structure,robot_premier_tour,[self(),4,salle4,Synchroniseur])),
    register(robot5,spawn(structure,robot_premier_tour,[self(),5,salle5,Synchroniseur])),
    register(robot6,spawn(structure,robot_premier_tour,[self(),6,salle6,Synchroniseur])),
    register(robot7,spawn(structure,robot_premier_tour,[self(),7,salle7,Synchroniseur])),
    register(robot8,spawn(structure,robot_premier_tour,[self(),8,salle8,Synchroniseur])),
    register(robot9,spawn(structure,robot_premier_tour,[self(),9,salle9,Synchroniseur])),
    synchroniseur().
	

% Permet aux robots de lock une salle tant qu'ils sont dedans
salle() ->
	receive
	    {IdRobot,demande} ->IdRobot!ok,
			   receive
			       libere -> salle()
			   end;
	    fin -> ok		       
	end.

% Suivant si on est le leader ou pas, on appelle la bonne fonction de construction d'arbre (seul le leader est actif au début)
salle_attente_leader(Voisins,ListePortes)->
    receive
	sync ->
	    receive
		{leader,neo} ->
		    arbre:calculArbreLeader(Voisins);
		{leader, nop} -> arbre:calculArbreGeneral(Voisins);
		X -> io:format('Le processus n est ni leader ni dans salle_attente_leader (~w)',[X])
	    end
    end.

% Les salles commencent par attendre la liste de leurs voisins sous deux formes : Une liste des directions et une liste des processus
salle_attente_voisins()->
    io:format("~w\n",[self()]),
    receive
	{voisins,Voisins,ListePortes,IdRobot} ->
	    IdRobot ! {voisins,ok},
	    salle_attente_leader(Voisins,ListePortes)
	end.

% Le robot au premier tour fait un tour complet de la salle pour détecter les portes
robot_premier_tour(IdRobot,NbRobot,Salle,Synchroniseur) ->
    R = robotlab:get_robot(NbRobot),
    O=robotlab:mur(R),
    S=robotlab:mur(R),
    E=robotlab:mur(R),
    N=robotlab:mur(R),
    ListePortes=[O,S,E,N],
    % On calcule les processus
    ListeProcessusVoisins = salles_calcul_processus_voisins(Salle),
    Voisins = salles_calcul_voisins(ListePortes,ListeProcessusVoisins,[]),
    %On envoie à la salle la liste de ses voisins
    Salle ! {voisins,Voisins,ListePortes,self()},
    receive 
	{voisins,ok} -> ok
    end,
    Leader = salles_calcul_leader(ListePortes,Salle),
    Synchroniseur ! sync,
    ok.

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
				Po or Pn ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle2 -> Pn = lists:nth(4,ListePortes),
			    if 
				Pn ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle3 -> Pe = lists:nth(3,ListePortes),
			    Pn = lists:nth(4,ListePortes),
			    if 
				Pe or Pn ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle6 -> Pe = lists:nth(3,ListePortes),
			    if 
				Pe ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle9 -> Pe = lists:nth(3,ListePortes),
			    Ps = lists:nth(2,ListePortes),
			    if 
				Pe or Ps ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle8 -> Ps = lists:nth(2,ListePortes),
			    if 
				Ps ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle7 -> Po = lists:nth(1,ListePortes),
			    Ps = lists:nth(2,ListePortes),
			    if 
				Po or Ps ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle4 -> Po = lists:nth(1,ListePortes),
			    if 
				Po ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle5 -> Salle ! {leader,nop}

	end.

salles_construction_arbre() ->
	ok.
	
robot_prochaine_salle(Pid) ->
	ok.

% Permet de synchroniser les 9 salles ou les 9 robots
synchroniseur() ->
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    receive
	sync ->
	     ok
    end,
    salle1!sync,
    salle2!sync,
    salle3!sync,
    salle4!sync,
    salle5!sync,
    salle6!sync,
    salle7!sync,
    salle8!sync,
    salle9!sync,
    ok.
    
