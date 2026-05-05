%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Apr 2026 14:24
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("typsoo").

-behaviour(gen_server).

%% API
-export([start_link/0, stop/0, crash/0]).
-export([addStation/2,
  addValue/4,
  removeValue/3,
  getOneValue/3,
  getStationMin/2,
  getStationMean/2,
  getDailyMean/2,
  getAirQualityIndex/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================



start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% Stops the server safely
stop() ->
  gen_server:stop(?SERVER).

%% Causes the server process to crash
crash() ->
  gen_server:cast(?SERVER, crash).

%% Wrapper functions for pollution module
addStation(Name, Coords) ->
  gen_server:call(?SERVER, {addStation, Name, Coords}).

addValue(Id, Date, Type, Value) ->
  gen_server:call(?SERVER, {addValue, Id, Date, Type, Value}).

removeValue(Id, Date, Type) ->
  gen_server:call(?SERVER, {removeValue, Id, Date, Type}).

getOneValue(Id, Date, Type) ->
  gen_server:call(?SERVER, {getOneValue, Id, Date, Type}).

getStationMin(Id, Type) ->
  gen_server:call(?SERVER, {getStationMin, Id, Type}).

getStationMean(Id, Type) ->
  gen_server:call(?SERVER, {getStationMean, Id, Type}).

getDailyMean(Type, Date) ->
  gen_server:call(?SERVER, {getDailyMean, Type, Date}).

getAirQualityIndex(Id, DateTime) ->
  gen_server:call(?SERVER, {getAirQualityIndex, Id, DateTime}).



%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
  %% Initialize the state with a new monitor
  {ok, pollution:create_monitor()}.

handle_call({addStation, Name, Coords}, _From, Monitor) ->
  case pollution:add_station(Name, Coords, Monitor) of
    {error, Reason} -> {reply, {error, Reason}, Monitor};
    NewMonitor      -> {reply, ok, NewMonitor}
  end;

handle_call({addValue, Id, Date, Type, Value}, _From, Monitor) ->
  case pollution:add_value(Id, Date, Type, Value, Monitor) of
    {error, Reason} -> {reply, {error, Reason}, Monitor};
    NewMonitor      -> {reply, ok, NewMonitor}
  end;

handle_call({removeValue, Id, Date, Type}, _From, Monitor) ->
  case pollution:remove_value(Id, Date, Type, Monitor) of
    {error, Reason} -> {reply, {error, Reason}, Monitor};
    NewMonitor      -> {reply, ok, NewMonitor}
  end;

handle_call({getOneValue, Id, Date, Type}, _From, Monitor) ->
  Result = pollution:get_one_value(Id, Date, Type, Monitor),
  {reply, Result, Monitor};

handle_call({getStationMin, Id, Type}, _From, Monitor) ->
  Result = pollution:get_station_min(Id, Type, Monitor),
  {reply, Result, Monitor};

handle_call({getStationMean, Id, Type}, _From, Monitor) ->
  Result = pollution:get_station_mean(Id, Type, Monitor),
  {reply, Result, Monitor};

handle_call({getDailyMean, Type, Date}, _From, Monitor) ->
  Result = pollution:get_daily_mean(Type, Date, Monitor),
  {reply, Result, Monitor};

handle_call({getAirQualityIndex, Id, DateTime}, _From, Monitor) ->
  Result = pollution:get_air_quality_index(Id, DateTime, Monitor),
  {reply, Result, Monitor}.

handle_cast(crash, Monitor) ->
  %% Perform an illegal operation (division by zero) to crash the server
  _Crash = 1 / 0,
  {noreply, Monitor}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
