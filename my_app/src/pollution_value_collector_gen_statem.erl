%%%-------------------------------------------------------------------
%%% @author typsoo
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. May 2026 11:25
%%%-------------------------------------------------------------------
-module(pollution_value_collector_gen_statem).
-author("typsoo").

-behaviour(gen_statem).

%% API
-export([start_link/0, stop/0, set_station/1, add_value/3, store_data/0]).

%% gen_statem callbacks
-export([init/1, callback_mode/0]).

-export([idle/3, collecting/3]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
  gen_statem:stop(?SERVER).

set_station(Station) ->
  gen_statem:call(?SERVER, {set_station, Station}).

add_value(Date, Type, Value) ->
  gen_statem:call(?SERVER, {add_value, Date, Type, Value}).

store_data() ->
  gen_statem:call(?SERVER, store_data).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================

init([]) ->
  Data = #{station => undefined, values => []},
  {ok, idle, Data}.

callback_mode() ->
  state_functions.

%%%===================================================================
%%% Internal functions
%%%===================================================================

idle({call, From}, {set_station, Station}, Data) ->
  NewData = Data#{station => Station},
  {next_state, collecting, NewData, [{reply, From, ok}]};

idle({call, From}, _, _Data) ->
  {keep_state_and_data, [{reply, From, {error, "You must set station first!"}}]}.



collecting({call, From}, {add_value, Date, Type, Value}, Data) ->
  OldValues = maps:get(values, Data),
  NewValues = [{Date, Type, Value} | OldValues],
  NewData = Data#{values => NewValues},
  {keep_state, NewData, [{reply, From, ok}]};

collecting({call, From}, store_data, Data) ->
  Station = maps:get(station, Data),
  Values = maps:get(values, Data),

  lists:foreach(fun({Date, Type, Value}) ->
    pollution_gen_server:addValue(Station, Date, Type, Value)
                end, Values),

  NewData = #{station => undefined, values => []},
  {next_state, idle, NewData, [{reply, From, ok}]};

collecting({call, From}, _, _Data) ->
  {keep_state_and_data, [{reply, From, {error, "Already collecting. Store data first."}}]}.