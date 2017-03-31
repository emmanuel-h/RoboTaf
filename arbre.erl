-module(arbre).
-export([calculArbreLeader/1,calculArbreGeneral/1]).

% On calcule les fils du leader dans une fonction à part
calculArbreLeader(Voisins) ->
    MessagePere = {pere,self()},
    Taille=length(Voisins),
    % On envoie à tous nos voisins qu'on est le père
    envoiListe(Voisins,MessagePere),
    % On attend que tous nos fils se soient bien activés
    receptionFilsLeader(Taille),
    % On attend que tous nos fils soient désactivés
    attenteDesactivationLeader(Taille).

% Si tous les fils du leader se sont désactivés c'est bon
attenteDesactivationLeader(Taille) when Taille == 0 ->
    ok;

% Tant que tous les fils du leader ne se sont pas désactivés on attend
attenteDesactivationLeader(Taille) when Taille > 0 ->
    receive
	{fils,desactive} ->	    attenteDesactivationLeader(Taille-1);
	{pere,PereUid} ->
	    PereUid ! {fils,nop,self()},
	    attenteDesactivationLeader(Taille)
    end.

% Quand il n'y a plus de voisins c'est bon
envoiListe([],_) ->
    ok;
% Tant qu'on a des voisins ont leur fait une demande de parenté
envoiListe([Fils|Voisins],MessagePere) ->
    Fils ! MessagePere,
    envoiListe(Voisins,MessagePere).

% Tous les fils du leader se sont activés
receptionFilsLeader(Taille) when Taille == 0 ->
    ok;
% le leader attend que tous les fils du leader s'active
receptionFilsLeader(Taille) when Taille > 0 ->
    receive
	{fils,ok,_} ->
	    receptionFilsLeader(Taille-1)
    end.

% Tous nos fils sont désactivés, on ne répond qu'aux processus qui veulent être nos père avec une réponse négative, et on attend de se faire activer pour continuer
desactive(Pere) ->
    receive
	{pere,PereUid} ->
	    PereUid ! {fils,nop,self()},
	    desactive(Pere);
	sync -> Pere
    end.

% Si on connaît tous nos fils et qu'ils sont tous désactivés, on envoie un message à notre père pour dire qu'on se désactive, puis on se désactive
receptionFilsGeneral(Fils,Taille,FilsDesactives,Pere) when ((Taille == 0) and (length(Fils) == FilsDesactives)) ->
    Pere ! {fils,desactive},
    %PosPere = calcul_position_pere(
    desactive(Pere);

%On connaît tous nos fils, mais ils ne sont pas tous désactivés
receptionFilsGeneral(Fils,Taille,FilsDesactives,Pere) when Taille == 0 ->
    receive
	{fils,desactive} ->
	    receptionFilsGeneral(Fils,Taille,FilsDesactives+1,Pere);
	{pere,PereUid} ->
	    PereUid ! {fils,nop,self()},
	    receptionFilsGeneral(Fils,Taille,FilsDesactives,Pere)
    end;

% Tant que Taille est supérieur à 0, c'est qu'on n'a pas encore reçu de réponse de tous nos voisins, et qu'on ne sait donc pas encore qui sont nos fils
receptionFilsGeneral(Fils,Taille,FilsDesactives,Pere) when Taille > 0 ->
    receive
	% Si on reçoit un refus de parenté, on décrémente Taille
	{fils,nop,_} ->
	    receptionFilsGeneral(Fils,Taille-1,FilsDesactives,Pere);
	% Si on reçoit une acceptation de parenté, on décrémente Taille et on ajoute Fils à la liste des fils
	{fils,ok,IdFils} ->
	    receptionFilsGeneral([IdFils|Fils],Taille-1,FilsDesactives,Pere);
	% Si on reçoit une demande de parenté, on la refuse
	{pere,PereUid} ->
	    PereUid ! {fils,nop,self()},
	    receptionFilsGeneral(Fils,Taille,FilsDesactives,Pere);
	% Si on reçoit une désactivation d'un de nos fils, on s'en souvient en incrémentant le nombre de fils désactivés
	{fils,desactive} ->
	    receptionFilsGeneral(Fils,Taille,FilsDesactives+1,Pere)
	%X ->io:write(X)
    end.

% La création de l'arbre pour tous les processus qui ne sont pas le leader
calculArbreGeneral(Voisins) ->
    MessagePere = {pere,self()},
    receive
	% Activation de notre processus via le message du père
	{pere,PereUid} ->
	    % On lui envoie une confirmation de parenté
	    PereUid ! {fils,ok,self()},
	    envoiListe(Voisins,MessagePere),
	    Taille=length(Voisins),
	    % On attend la réponse de nos voisins
	    receptionFilsGeneral([],Taille,0,PereUid)
    end.
