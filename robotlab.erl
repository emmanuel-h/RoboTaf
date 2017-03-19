-module(robotlab).
-export([get_robot/1,mur/1,porte/1,sort/1,franchit/1,led/1,reset/0, labyrinthe/3]).

%% CALCUL DU PID DE LA BOITE DE MESSAGES DE JAVA
%% FONCTION PRIVE !!!
serveur() ->
	  {_,H} = inet:gethostname(),
	  {mail,list_to_atom("robotlab@" ++ H)}.

%% DIALOGUE AVEC L'ACCUEIL DU ROBOT
% Obtenir le PID du serveur d'un robot
get_robot(N) ->
	     {N,serveur()}.

%% CONTROLE DU ROBOT
%% REMARQUE : dans la suite {N,S} designe le "pid" du robot N donne par la fonction get_robot(N)

%% Le robot suit le mur et renvoie si oui ou non le mur a une porte
%% ATTENTION : les messages de la forme {robotlab,_} sont reserves au simulateur
%% Ils ne doivent pas etre lu ou transmis par votre programme 

mur({N,S}) -> 
	   S!{self(),"m",N},
	   receive
		{robotlab,X} -> X
	end.

%% Avance le robot devant la porte
%% Pre condition : le robot longe un mur contenant une porte
porte({N,S}) -> 
	   S!{self(),"p",N},
	   receive
		{robotlab,X} -> X
	end.

%% Le robot franchit la porte
%% Pre condition : le robot est devant une porte (autre que la sortie)
franchit({N,S}) -> 
	   S!{self(),"f",N},
	   receive
		{robotlab,X} -> X
	end.

%% Le robot franchit la porte de sortie du labyrinthe
%% Pre condition : le robot est devant la sortie
sort({N,S}) -> 
	   S!{self(),"s",N},
	   receive
		{robotlab,X} -> X
	end.

%% Modifie l'etat de la led du robot
led({N,S}) -> 
	   S!{self(),"l",N},
	   ok.

%% Reset du labyrinthe
%% Remet les robots dans leurs positions initiales
reset() -> 
	serveur()!{self(),"r"},
	ok.

%% Modifie la configuration des portes :
%% - N designe le mur contenant la porte de sortie : 0 designe la porte en haut a gauche, les portes sont numerotes dans l'ordre des aiguilles d'une montre
%% - P donne la configuation des murs interieurs (porte ou pas porte) sous la forme d'une chaine de 12 caracteres 0 ou 1. Les portes sont ordonnés de haut en bas et de gauche a droite.
%% - Robot donne la liste des robots sous la forme d'une chaine de caractères



labyrinthe(N,P,Robot) ->
	serveur()!{self(),"b",N,P,Robot},
	receive
		X -> X
	end.
