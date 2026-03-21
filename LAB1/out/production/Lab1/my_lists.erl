%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Mar 2026 11:57
%%%-------------------------------------------------------------------
-module(my_lists).
-author("typsoo").

%% API
-export([contains/2, duplicate_elements/1, sum_floats/1]).

contains([], _)-> false;
contains([A | _], A)-> true;
contains( [_ | B], A) -> contains(B, A).


duplicate_elements([])->[];
duplicate_elements([A | B]) ->
  [A, A] ++ duplicate_elements(B).



sum_floats(A)->sum_floats(A, 0.0).

sum_floats([], Acc) ->
  Acc;
sum_floats([A | B], Acc) when is_float(A)->
  sum_floats(B, Acc + A);
sum_floats([_ | B], Acc)->
  sum_floats(B, Acc).

