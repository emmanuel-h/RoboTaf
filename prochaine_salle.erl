-module(prochaine_salle).
-export([robot_prochaine_salle/4, changer_salle/6]).

% --- Position du robot ---
% Ouest : haut gauche
% Sud : bas gauche
% Est : bas droit
% Nord : haut droit
% -------------------------

robot_prochaine_salle(Pid, IdSalle, Position, IdLeader) ->
	IdSalle!{pere, Pid},
	receive
		{pere, PosPere, IdPere} ->
			changer_salle(Pid, IdSalle, Position, PosPere, IdPere, IdLeader)
	end.
	
changer_salle(Pid, IdSalle, Position, PosPere, IdPere, IdLeader) when Position == PosPere ->
	robotlab:porte({Pid, IdSalle}),
	case PosPere of
		nord -> NewPos = sud;
		sud -> NewPos = nord;
		est -> NewPos = ouest;
		ouest -> NewPos = est
	end,
	if 
		IdSalle == IdLeader ->
			robotlab:sort({Pid, IdSalle}),
			IdSalle ! libere,
			ok;
		true ->
			IdPere ! {entrer, Pid},
			receive
				{ok, IdPere} ->
					robotlab:franchit({Pid, IdSalle}),
					IdSalle ! libere,
					robot_prochaine_salle(Pid, IdPere, NewPos, IdLeader)
			end
	end;
changer_salle(Pid, IdSalle, Position, PosPere, IdPere, IdLeader) ->
	robotlab:mur({Pid, IdSalle}),
	case Position of
		nord -> NewPos = ouest;
		sud -> NewPos = est;
		est -> NewPos = nord;
		ouest -> NewPos = sud
	end,
	changer_salle(Pid, IdSalle, NewPos, PosPere, IdPere, IdLeader).

