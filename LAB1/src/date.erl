%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Mar 2026 11:44
%%%-------------------------------------------------------------------
-module(date).
-author("typsoo").
-include("records.hrl").

%% API
-export([example_date/0]).


example_date() ->
  P1 = #measurement{
    station  = "Krakow_Centrum",
    datetime = {{2026, 1, 15}, {4, 0, 53}},
    readings = [{pm10, 45.5}, {pm2_5, 28.2}, {temperature, 15.0}]
  },

  P2 = #measurement{
    station  = "Krakow_Krowodrza",
    datetime = {{2026, 11, 11}, {23, 5, 0}},
    readings = [{pm10, 30.1}, {pressure, 1013.25}, {humidity, 45.0}]
  },

  P3 = #measurement{
    station  = "Krakow_Nowa_Huta",
    datetime = {{2026, 2, 23}, {12, 10, 0}},
    readings = [{pm1, 12.0}, {pm2_5, 20.0}, {pm10, 35.0}, {temperature, 14.5}]
  },

  P4 = #measurement{
    station  = "Krakow_Podgorze",
    datetime = {date(), time()},
    readings = [{temperature, 16.0}, {humidity, 40.0}]
  },

  [P1, P2, P3, P4].