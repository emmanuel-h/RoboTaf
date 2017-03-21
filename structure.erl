-module(structure).
-export([start/0,salle/0,salle_debut/0,robot_premier_tour/3,salles_calcul_leader/2]).

start() ->
	register(salle1,spawn(structure,salle_debut,[])),
	register(salle2,spawn(structure,salle_debut,[])),
	register(salle3,spawn(structure,salle_debut,[])),
	register(salle4,spawn(structure,salle_debut,[])),
	register(salle5,spawn(structure,salle_debut,[])),
	register(salle6,spawn(structure,salle_debut,[])),
	register(salle7,spawn(structure,salle_debut,[])),
	register(salle8,spawn(structure,salle_debut,[])),
	register(salle9,spawn(structure,salle_debut,[])),
	register(robot1,spawn(structure,robot_premier_tour,[self(),1,salle1])),
	register(robot2,spawn(structure,robot_premier_tour,[self(),2,salle2])),
	register(robot3,spawn(structure,robot_premier_tour,[self(),3,salle3])),
	register(robot4,spawn(structure,robot_premier_tour,[self(),4,salle4])),
	register(robot5,spawn(structure,robot_premier_tour,[self(),5,salle5])),
	register(robot6,spawn(structure,robot_premier_tour,[self(),6,salle6])),
	register(robot7,spawn(structure,robot_premier_tour,[self(),7,salle7])),
	register(robot8,spawn(structure,robot_premier_tour,[self(),8,salle8])),
	register(robot9,spawn(structure,robot_premier_tour,[self(),9,salle9])).
	
    
salle() ->
	receive
	    {IdRobot,demande} ->IdRobot!ok,
			   receive
			       libere -> salle()
			   end;
	    fin -> ok		       
	end.


salle_debut()->
	receive
		{portes,ListePortes,IdSalle} -> io:format("~w ~w \n",[self(),ListePortes]),
					IdSalle ! {portes,ok}, 
					salle_debut();
		{leader,neo} -> io:format("je suis leader ~w \n",[self()]),salle();  
		{leader, nop} -> io:format("je ne suis pas leader ~w \n",[self()]),salle()			
		
	
	end.


robot_premier_tour(IdRobot,NbRobot,Salle) ->	
	R = robotlab:get_robot(NbRobot),
	O=robotlab:mur(R),
	S=robotlab:mur(R),
	E=robotlab:mur(R),
	N=robotlab:mur(R),
	ListePortes=[O,S,E,N],
	io:format("~w ~w \n",[NbRobot,ListePortes]),
	Salle ! {portes,ListePortes,self()},
	receive 
		{portes,ok} -> ok,io:format("~w OK \n",[NbRobot])
	end,
	Leader = salles_calcul_leader(ListePortes,Salle), 
	ok.

salles_calcul_leader(ListesPortes,Salle) ->
	case Salle of 
		salle1 -> Po = lists:nth(1,ListesPortes),
			    Pn = lists:nth(4,ListesPortes),
			    if 
				Po or Pn ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle2 -> Pn = lists:nth(4,ListesPortes),
			    if 
				Pn ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle3 -> Pe = lists:nth(3,ListesPortes),
			    Pn = lists:nth(4,ListesPortes),
			    if 
				Pe or Pn ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle6 -> Pe = lists:nth(3,ListesPortes),
			    if 
				Pe ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle9 -> Pe = lists:nth(3,ListesPortes),
			    Ps = lists:nth(2,ListesPortes),
			    if 
				Pe or Ps ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle8 -> Ps = lists:nth(2,ListesPortes),
			    if 
				Ps ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle7 -> Po = lists:nth(1,ListesPortes),
			    Ps = lists:nth(2,ListesPortes),
			    if 
				Po or Ps ->
					Salle ! {leader,neo};
			 
  			    true -> Salle ! {leader, nop}
			    end;
		salle4 -> Po = lists:nth(1,ListesPortes),
			    if 
				Po ->
					Salle ! {leader,neo};
				true -> Salle ! {leader, nop}
			    end;
		salle5 -> Salle ! {leader,nop}

	end,
			
	ok.



salles_construction_arbre() ->
	ok.
	
robot_prochaine_salle(Pid) ->
	ok.
