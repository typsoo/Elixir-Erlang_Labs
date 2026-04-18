%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Mar 2026 13:38
%%%-------------------------------------------------------------------
-module(sort).
-author("typsoo").

%% API
-export([qs/1]).


less_than(List, Arg) -> [X || X<- List, X<Arg].

grt_eq_than(List, Arg) -> [X || X<- List, X>=Arg].

qs([]) -> [];
qs([Pivot|Tail]) -> qs( less_than(Tail,Pivot) ) ++ [Pivot] ++ qs( grt_eq_than(Tail,Pivot) ).