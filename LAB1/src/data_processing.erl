%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Mar 2026 17:08
%%%-------------------------------------------------------------------
-module(data_processing).
-author("typsoo").
-include("records.hrl").

%% API
-export([number_of_readings/2, calculate_min_max/2, calculate_mean/2]).


number_of_readings(Readings, Date) ->
  length([R || R <- Readings,
    element(1, R#measurement.datetime) =:= Date,
    is_list(R#measurement.readings)]).



calculate_min_max(Readings, Type) ->
  MinMax = fun
             (X, {undefined, undefined})-> {X, X};
             (X, {Min, Max}) when X < Min -> {X, Max};
             (X, {Min, Max}) when X > Max -> {Min, X};
             (_, V) -> V
           end,
  L = [V || R <- Readings, {T, V} <- R#measurement.readings, T =:= Type],
  lists:foldl(MinMax, {undefined, undefined}, L).





calculate_mean(Readings, Type) ->
  L = [V || R <- Readings, {T, V} <- R#measurement.readings, T =:= Type],

  case length(L) of
    0 -> undefined;
    Len -> lists:sum(L) / Len
  end.


