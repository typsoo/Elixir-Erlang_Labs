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



min_max(X, {Min, Max}) when X < Min -> {X, Max};
min_max(X, {Min, Max}) when X > Max -> {Min, X};
min_max(_, V) -> V.

calculate_min_max(Readings, Type) ->
  MinMax = fun
             (X, {Min, Max}) when X < Min -> {X, Max};
             (X, {Min, Max}) when X > Max -> {Min, X};
             (_, V) -> V
           end,
  L = [V || R <- Readings, {Type, V} <- R#measurement.readings],
  lists:foldl(MinMax, {1000, -1000}, [V || {_, V} <- L]).





calculate_mean(Readings, Type) ->
  {Sum, Cnt} = calculate_mean(Readings, Type, 0, 0),
  case Cnt of
    0 -> undefined;
    _Else -> Sum / Cnt
  end.

calculate_mean([], _, Sum, Cnt) -> {Sum, Cnt};
calculate_mean([Reading | Tail], Type, Sum, Cnt) ->
  case Reading of
    {_Station, {_Date, _Time}, Measurements} when is_list(Measurements) ->

      case find_measurement(Type, Measurements) of
        Value when is_number(Value) ->
          calculate_mean(Tail, Type, Sum+Value, Cnt+1);

        _Else ->
          calculate_mean(Tail, Type, Sum, Cnt)
      end;

    _Else ->
      calculate_mean(Tail, Type, Sum, Cnt)
  end.


find_measurement(_, []) -> undefined;
find_measurement(Type, [{Type, Value} | _]) -> Value;
find_measurement(Type, [_ | Tail]) -> find_measurement(Type, Tail).