%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Apr 2026 11:43
%%%-------------------------------------------------------------------
-module(qs_tasks).
-author("typsoo").

%% API
-export([qs/1, random_elems/3, il/1, compare_speeds/3, generate_lists/1, sort_lists/1, qs_proc/2, sort_lists_proc/1]).


less_than(List, Arg) -> [X || X<- List, X<Arg].

grt_eq_than(List, Arg) -> [X || X<- List, X>=Arg].

qs([])-> [];
qs([Pivot|Tail]) -> qs( less_than(Tail,Pivot) ) ++ [Pivot] ++ qs( grt_eq_than(Tail,Pivot) ).

qs_proc(List, Pid) -> Pid ! {self(), qs(List)}.

sort_lists_proc(Lists) ->
  Pids = [spawn(?MODULE, qs_proc, [List, self()]) || List <- Lists],
  [receive {_, L} -> L end || _ <- Pids].

random_elems(N, Min, Max) ->
  [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

generate_lists(N) ->
  [random_elems(10000, 1, 10000) || _ <- lists:seq(1, N)].

sort_lists(Lists) -> [qs(L) || L <- Lists].

compare_speeds(List, Fun1, Fun2) ->
  {T1, _} = timer:tc(Fun1, [List]),
  {T2, _} = timer:tc(Fun2, [List]),

  io:format("My qs: ~b~n", [T1]),
  io:format("Lib's qs: ~b~n", [T2]).


il(A)-> length(lists:filter(fun(El)-> El rem 3 == 0 end, A)).
