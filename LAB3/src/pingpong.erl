%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2026 13:27
%%%-------------------------------------------------------------------
-module(pingpong).
-author("typsoo").

%% API
-export([ping_loop/1, pong_loop/0, start/0, play/1, stop/0]).


start() ->
  case lists:member(ping, registered()) of
   true -> ok;
   false ->
     register(ping, spawn(pingpong, ping_loop, [0])),
     register(pong, spawn(pingpong, pong_loop, []))
  end.

play(N) -> ping ! N.

stop() ->
  ping ! stop,
  pong ! stop,
  ok.

ping_loop(State) ->
  receive
    stop -> ok;
    0 ->
      io:format("Ping is 0~n"),
      io:format("Ping's State is ~b~n", [State]),
      ping_loop(0);
    N when is_integer(N) ->
      NewState = State + N,
      timer:sleep(200),
      io:format("Ping is ~b~n",  [N]),
      io:format("Ping's State is ~b~n", [State]),
      pong ! N - 1,
      ping_loop(NewState)
    after
      20000 -> stop()
  end.

pong_loop() ->
  receive
    stop -> ok;
    0 ->
      io:format("Pong is 0~n"),
      pong_loop();
    N when is_integer(N) ->
      timer:sleep(200),
      io:format("Pong is ~b~n", [N]),
      ping ! N - 1,
      pong_loop()
    after
      20000 -> stop()

  end.