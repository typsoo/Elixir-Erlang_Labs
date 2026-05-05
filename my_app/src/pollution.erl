%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Apr 2026 19:06
%%%-------------------------------------------------------------------
-module(pollution).
-author("typsoo").

%% API
-export([create_monitor/0,
         add_station/3,
         add_value/5,
         remove_value/4,
         get_one_value/4,
         get_station_min/3,
         get_station_mean/3,
         get_daily_mean/3,
         get_air_quality_index/3]).

-record(measurement,  {coords, date, type}).

-record(monitor, {
  coords_to_name = #{},
  name_to_coords = #{},
  measurements  = #{}
}).

create_monitor() -> #monitor{}.

%%-------------------------------------------------------------%%


add_station(Name, Coords, Monitor) ->
  IsNameEx = maps:is_key(Name, Monitor#monitor.name_to_coords),
  IsCoordsEx = maps:is_key(Coords, Monitor#monitor.coords_to_name),
  case {IsNameEx, IsCoordsEx} of

    {true, _} -> {error, name_already_exists};
    {_, true} -> {error, coords_already_exists};

    {false, false} ->
      Monitor#monitor{
        name_to_coords = maps:put(Name, Coords, Monitor#monitor.name_to_coords),
        coords_to_name = maps:put(Coords, Name, Monitor#monitor.coords_to_name)
      }
  end.

%%-------------------------------------------------------------%%


add_value(Name, Date, Type, Value, Monitor) when is_list(Name) ->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> add_value({X, Y}, Date, Type, Value, Monitor);
    error -> {error, station_not_found}
  end;

add_value({X, Y}, {{_Yr, _Mo, _Da}, {_H, _M, _S}} = Date, Type, Value, Monitor)->
  Key = #measurement{coords = {X, Y}, date = Date, type = Type},

  IsStationEx = maps:is_key({X, Y}, Monitor#monitor.coords_to_name),
  IsMeasurementEx = maps:is_key(Key, Monitor#monitor.measurements),

  case {IsStationEx, IsMeasurementEx} of

    {false, _} -> {error, station_not_found};

    {true, true} -> {error, measurement_already_exists};

    {true, false} ->
      Monitor#monitor{
        measurements = maps:put(Key, Value, Monitor#monitor.measurements)
      }
  end;

add_value({_X, _Y}, _WrongDate, _Type, _Value, _Monitor) -> {error, invalid_date_format}.


%%-------------------------------------------------------------%%


remove_value(Name, Date, Type, Monitor) when is_list(Name) ->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> remove_value({X, Y}, Date, Type, Monitor);
    error -> {error, station_not_found}
  end;

remove_value({X, Y}, Date, Type, Monitor) ->
  Key = #measurement{coords = {X, Y}, date = Date, type = Type},

  IsStationEx = maps:is_key({X, Y}, Monitor#monitor.coords_to_name),
  IsMeasurementEx = maps:is_key(Key, Monitor#monitor.measurements),

  case {IsStationEx, IsMeasurementEx} of
    {false, _} -> {error, station_not_found};

    {true, false} -> {error, measurement_not_found};

    {true, true} -> Monitor#monitor{measurements = maps:remove(Key, Monitor#monitor.measurements)}
  end.


%%-------------------------------------------------------------%%


get_one_value(Name, Date, Type, Monitor) when is_list(Name) ->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> get_one_value({X, Y}, Date, Type, Monitor);
    error -> {error, station_not_found}
  end;

get_one_value({X, Y}, Date, Type, Monitor) ->
  Key = #measurement{coords = {X, Y}, date = Date, type = Type},

  IsStationEx = maps:is_key({X, Y}, Monitor#monitor.coords_to_name),
  IsMeasurementEx = maps:find(Key, Monitor#monitor.measurements),

  case {IsStationEx, IsMeasurementEx} of
    {false, _} -> {error, station_not_found};

    {true, error} -> {error, measurement_not_found};

    {true, {ok, Value}} -> Value
  end.


%%-------------------------------------------------------------%%


get_station_min(Name, Type, Monitor) when is_list(Name)->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> get_station_min({X, Y}, Type, Monitor);
    error -> {error, station_not_found}
  end;

get_station_min({X, Y}, Type, Monitor) ->
  case maps:is_key({X, Y}, Monitor#monitor.coords_to_name) of
    false -> {error, station_not_found};
    true ->
      AllMeasurements = maps:to_list(Monitor#monitor.measurements),

      Values = [Val || {#measurement{coords = C, type = T}, Val} <- AllMeasurements,
        C =:= {X, Y},
        T =:= Type
      ],

      find_min(Values)
  end.


%%-------------------------------------------------------------%%

get_station_mean(Name, Type, Monitor) when is_list(Name)->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> get_station_mean({X, Y}, Type, Monitor);
    error -> {error, station_not_found}
  end;

get_station_mean({X, Y}, Type, Monitor) ->
  case maps:is_key({X, Y}, Monitor#monitor.coords_to_name) of
    false -> {error, station_not_found};
    true ->
      AllMeasurements = maps:to_list(Monitor#monitor.measurements),

      Values = [Val || {#measurement{coords = C, type = T}, Val} <- AllMeasurements,
        C =:= {X, Y},
        T =:= Type
      ],

      find_mean(Values)
  end.


%%-------------------------------------------------------------%%


get_daily_mean(Type, Date, Monitor) ->
  AllMeasurements = maps:to_list(Monitor#monitor.measurements),

  AllValues = [Val || {#measurement{date = {D, _}, type = T}, Val} <- AllMeasurements,
    D =:= Date,
    T =:= Type],

    find_mean(AllValues).



%%-------------------------------------------------------------%%


get_air_quality_index(Name, DateTime, Monitor) when is_list(Name) ->
  case maps:find(Name, Monitor#monitor.name_to_coords) of
    {ok, {X, Y}} -> get_air_quality_index({X, Y}, DateTime, Monitor);
    error -> {error, station_not_found}
  end;

get_air_quality_index({A, B}, {{Y, M1, D}, {H, M2, _}}, Monitor) ->
  case maps:is_key({A, B}, Monitor#monitor.coords_to_name) of
    false -> {error, station_not_found};
    true ->
      AllMeasurements = maps:to_list(Monitor#monitor.measurements),

      Percentages = [
        (Value / get_norm(T)) * 100
        ||
        {#measurement{coords = C, date = {{Yr, Mo, Da}, {Ho, Mi, _}}, type = T}, Value} <- AllMeasurements,
        C =:= {A, B},
        {{Yr, Mo, Da}, {Ho, Mi}} =:= {{Y, M1, D}, {H, M2}},
        get_norm(T) =/= undefined
      ],

      find_max(Percentages)
  end.



%%-------------------------------------------------------------%%


get_norm("PM10") -> 50.0;
get_norm("PM2.5") -> 30.0;
get_norm(_) -> undefined.

find_max([]) -> {error, no_measurements};
find_max(L) -> lists:max(L).

find_min([]) -> {error, no_measurements};
find_min(L) -> lists:min(L).

find_mean(L) when length(L) == 0 -> {error, no_measurements};
find_mean(L) -> lists:sum(L) / length(L).

