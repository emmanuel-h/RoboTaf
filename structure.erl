-module(structure).
-export([]).

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

robot_premier_tour(IdRobot) ->
	ok.

salles_calcul_leader() ->
	ok.
	
salles_construction_arbre() ->
	ok.
	
robot_prochaine_salle(Pid) ->
	ok.
