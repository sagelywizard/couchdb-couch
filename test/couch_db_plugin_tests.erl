% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

-module(couch_db_plugin_tests).

-export([
    validate_dbname/2
]).

-include_lib("couch/include/couch_eunit.hrl").
-include_lib("couch/include/couch_db.hrl").

-record(ctx, {pid, handle}).

setup() ->
    error_logger:tty(false),
    application:start(couch_epi),
    {ok, FunctionsPid} = couch_epi_functions:start_link(
        test_app, {epi_key, couch_db}, {modules, [?MODULE]},
        [{interval, 100}]),
    ok = couch_epi_functions:wait(FunctionsPid),
    #ctx{pid = FunctionsPid, handle = couch_epi:get_handle(couch_db)}.

teardown(#ctx{pid = FunctionsPid}) ->
    erlang:unlink(FunctionsPid),
    couch_epi_functions:stop(FunctionsPid),
    application:stop(couch_epi),
    ok.

validate_dbname({true, _Db}, _) -> true;
validate_dbname({false, _Db}, _) -> false;
validate_dbname({fail, _Db}, _) -> throw(validate_dbname).

callback_test_() ->
    {
        "callback tests",
        {
            foreach, fun setup/0, fun teardown/1,
            [
                fun validate_dbname_match/0,
                fun validate_dbname_no_match/0,
                fun validate_dbname_throw/0
            ]
        }
    }.


validate_dbname_match() ->
    ?_assertMatch(
        {true, [validate_dbname, db]},
        couch_db_plugin:validate_dbname({true, [db]}, db)).

validate_dbname_no_match() ->
    ?_assertMatch(
        {false, [db]},
        couch_db_plugin:validate_dbname({false, [db]}, db)).

validate_dbname_throw() ->
    ?_assertThrow(
        validate_dbname,
        couch_db_plugin:validate_dbname({fail, [db]}, db)).