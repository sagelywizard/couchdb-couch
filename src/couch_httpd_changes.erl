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

-module(couch_httpd_changes).

-export([handle_changes_req/2]).

-include_lib("couch/include/couch_db.hrl").

handle_changes_req(#httpd{method='POST'}=Req, Db) ->
    couch_httpd:validate_ctype(Req, "application/json"),
    handle_changes_req1(Req, Db);
handle_changes_req(#httpd{method='GET'}=Req, Db) ->
    handle_changes_req1(Req, Db);
handle_changes_req(#httpd{path_parts=[_,<<"_changes">>]}=Req, _Db) ->
    couch_httpd:send_method_not_allowed(Req, "GET,HEAD,POST").

handle_changes_req1(Req, #db{name=DbName}=Db) ->
    ChangesArgs = couch_util:parse_changes_query(Req, Db),
    ChangesFun = couch_changes:handle_changes(ChangesArgs, Req, Db),
    couch_httpd_db:handle_changes(Req, Db, ChangesArgs, ChangesFun).
