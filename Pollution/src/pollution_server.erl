%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2026 15:45
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("typsoo").
%-import(pollution).

%% API
-export([start/0,
         stop/0,
         init/0,
         loop/1,
         add_station/2,
         add_value/4,
         remove_value/3,
         get_one_value/3,
         get_station_min/2,
         get_station_mean/2,
         get_daily_mean/2,
         get_air_quality_index/2]).

stop() ->
  pollution_server ! stop,
  ok.

start() ->
  case lists:member(pollution_server, registered()) of
    true -> ok;
    false -> register(pollution_server, spawn(?MODULE, init, []))
  end.

init() ->
  Monitor = pollution:create_monitor(),
  loop(Monitor).

loop(Monitor) ->
  receive
    {add_station, Pid, Name, Coords} ->
      case pollution:add_station(Name, Coords, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        NewMonitor ->
          Pid ! NewMonitor,
          loop(NewMonitor)
      end;

    {add_value, Pid, Name, Date, Type, Value} ->
      case pollution:add_value(Name, Date, Type, Value, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        NewMonitor ->
          Pid ! NewMonitor,
          loop(NewMonitor)
      end;

    {remove_value, Pid, Name, Date, Type} ->
      case pollution:remove_value(Name, Date, Type, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        NewMonitor ->
          Pid ! NewMonitor,
          loop(NewMonitor)
      end;

    {get_one_value, Pid, Name, Date, Type} ->
      case pollution:get_one_value(Name, Date, Type, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        Value ->
          Pid ! Value,
          loop(Monitor)
      end;

    {get_station_min, Pid, Name, Type} ->
      case pollution:get_station_min(Name, Type, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        Value ->
          Pid ! Value,
          loop(Monitor)
      end;

    {get_station_mean, Pid, Name, Type} ->
      case pollution:get_station_mean(Name, Type, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        Value ->
          Pid ! Value,
          loop(Monitor)
      end;


    {get_daily_mean, Pid, Type, Date} ->
      case pollution:get_daily_mean(Type, Date, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        Value ->
          Pid ! Value,
          loop(Monitor)
      end;

    {get_air_quality_index, Pid, Name, DateTime} ->
      case pollution:get_air_quality_index(Name, DateTime, Monitor) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(Monitor);
        Value ->
          Pid ! Value,
          loop(Monitor)
      end;

    stop -> ok
  end.


add_station(Name, Coords) ->
  pollution_server ! {add_station, self(), Name, Coords},
  receive
    Reply -> Reply
  end.

add_value(Name, Date, Type, Value) ->
  pollution_server ! {add_value, self(), Name, Date, Type, Value},
  receive
    Reply -> Reply
  end.

remove_value(Name, Date, Type) ->
  pollution_server ! {remove_value, self(), Name, Date, Type},
  receive
    Reply -> Reply
  end.

get_one_value(Name, Date, Type) ->
  pollution_server ! {get_one_value, self(), Name, Date, Type},
  receive
    Reply -> Reply
  end.

get_station_min(Name, Type) ->
  pollution_server ! {get_station_min, self(), Name, Type},
  receive
    Reply -> Reply
  end.

get_station_mean(Name, Type) ->
  pollution_server ! {get_station_mean, self(), Name, Type},
  receive
    Reply -> Reply
  end.

get_daily_mean(Type, Date) ->
  pollution_server ! {get_daily_mean, self(), Type, Date},
  receive
    Reply -> Reply
  end.

get_air_quality_index(Name, DateTime) ->
  pollution_server ! {get_air_quality_index, self(), Name, DateTime},
  receive
    Reply -> Reply
  end.