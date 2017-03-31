-module(synchroniseurs).
-export([synchroniseur/0,activationSalles/0,syncAll/0]).

% Permet de synchroniser les 9 salles et/ou les 9 robots
synchroniseur() ->
    theNineReceives(),
    activationSalles().
    
theNineReceives()->
    theNineReceives(9).

theNineReceives(X) when X == 0 ->
    ok;
theNineReceives(X) when X > 0 ->
    receive
	sync ->
	     ok
    end,
    theNineReceives(X-1).

syncAll()->
    theNineReceives(),
    activationSalles(),
    activationRobots().

activationRobots()->
    robot1!sync,
    robot2!sync,
    robot3!sync,
    robot4!sync,
    robot5!sync,
    robot6!sync,
    robot7!sync,
    robot8!sync,
    robot9!sync.

activationSalles()->
    salle1!sync,
    salle2!sync,
    salle3!sync,
    salle4!sync,
    salle5!sync,
    salle6!sync,
    salle7!sync,
    salle8!sync,
    salle9!sync.
