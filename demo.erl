-module(demo).
-export([start/0,rob1/1,rob3/1,rob7/1,salle/0]).

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

	register(robot1,spawn(demo,rob1,[self()])),
	register(robot3,spawn(demo,rob3,[self()])),
	register(robot7,spawn(demo,rob7,[self()])),

 
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
	    {X,demande} -> X!ok,
			   receive
			       libere -> salle()
			   end;
	    fin -> ok
			       
	end.

	
rob1(X) ->
       salle1!{self(),demande},
       receive
	ok -> ok
       end,
       R=robotlab:get_robot(1),
       robotlab:led(R),
       robotlab:mur(R),
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:led(R),
       salle2!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle1!libere,
       robotlab:mur(R),
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:sort(R),
       salle2!libere,
       X!fin.

rob7(X) ->
       salle7!{self(),demande},
       receive
	ok -> ok
       end,
       R=robotlab:get_robot(7),
       robotlab:led(R),
       robotlab:mur(R),
       robotlab:mur(R),
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:led(R),
       salle4!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle7!libere,
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:led(R),
       salle1!{self(),demande},       
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle4!libere,
       robotlab:porte(R),
       robotlab:led(R),
       salle2!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle1!libere,
       robotlab:mur(R),
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:sort(R),
       salle2!libere,
       X!fin.



rob3(X) ->
       salle3!{self(),demande},
       receive
	ok -> ok
       end,
       R=robotlab:get_robot(3),
       robotlab:led(R),
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:led(R),
       salle6!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle3!libere,
       robotlab:porte(R),
       robotlab:led(R),
       salle5!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle6!libere,
       robotlab:porte(R),
       robotlab:led(R),
       salle2!{self(),demande},
       receive
	ok -> ok
       end,
       robotlab:led(R),
       robotlab:franchit(R),
       salle5!libere,
       robotlab:mur(R),
       robotlab:porte(R),
       robotlab:sort(R),
       salle2!libere,
       X!fin.

