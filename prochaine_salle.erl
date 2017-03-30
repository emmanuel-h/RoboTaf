-module(prochaine_salle).
-export([robot_prochaine_salle/3,changer_salle/5]).

% --- Position du robot ---
% Ouest : haut gauche
% Sud : bas gauche
% Est : bas droit
% Nord : haut droit
% -------------------------

robot_prochaine_salle(IdSalle, Position,R) ->
    IdSalle!{pere, self()},
    receive
	{pere, PosPere, IdPere} ->
	    changer_salle(IdSalle, Position, PosPere, IdPere,R)
    end.
	
changer_salle(IdSalle, Position, PosPere, IdPere,R) when Position == PosPere ->
    robotlab:porte(R),
    case PosPere of
	nord -> NewPos = est;
	sud -> NewPos = ouest;
	est -> NewPos = sud;
	ouest -> NewPos = nord
    end,
    if 
	IdPere == -1 ->
	    robotlab:sort(R),
	    IdSalle ! libere,
	    ok;
	true ->
	    robotlab:led(R),
	    IdPere ! {entrer, self()},
	    receive
		ok ->
		    robotlab:led(R),
		    robotlab:franchit(R),
		    IdSalle ! libere,
		    robot_prochaine_salle(IdPere, NewPos,R)
	    end
    end;
changer_salle(IdSalle, Position, PosPere, IdPere,R) ->
	robotlab:mur(R),
	case Position of
		nord -> NewPos = ouest;
		sud -> NewPos = est;
		est -> NewPos = nord;
		ouest -> NewPos = sud
	end,
	changer_salle(IdSalle, NewPos, PosPere, IdPere,R).
