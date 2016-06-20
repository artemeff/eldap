-include("ELDAPv3.hrl").
% -include_lib("eunit/include/eunit.hrl").

-define(LDAP_VERSION, 3).
-define(LDAP_PORT, 389).
-define(LDAPS_PORT, 636).
-define(DENIED_TCP_OPTS, [active, binary, deliver, list, mode, packet]).

%%% For debug purposes
%%-define(PRINT(S, A), io:fwrite("~w(~w): " ++ S, [?MODULE,?LINE|A])).
-define(PRINT(S, A), true).

% -define(elog(S, A), error_logger:info_msg("~w(~w): "++S,[?MODULE,?LINE|A])).

%%%
%%% Main ELDAP record
%%%
-record(eldap,
	{ version = ?LDAP_VERSION
	, host                	% Host running LDAP server
	, port = ?LDAP_PORT   	% The LDAP server port
	, fd                  	% Socket filedescriptor.
	, prev_fd	     		% Socket that was upgraded by start_tls
	, binddn = ""         	% Name of the entry to bind as
	, passwd              	% Password for (above) entry
	, id = 0              	% LDAP Request ID
	, log                 	% User provided log function
	, timeout = infinity  	% Request timeout
	, anon_auth = false   	% Allow anonymous authentication
	, ldaps = false       	% LDAP/LDAPS
	, using_tls = false   	% true if LDAPS or START_TLS executed
	, tls_opts = []       	% ssl:ssloption()
	, tcp_opts = []       	% inet6 support
	, reply_to 		       	% pid for async calls
	}).

%%%
%%% Search input parameters
%%%
-record(eldap_search,
	{ base = []              % Baseobject
	, filter = []            % Search conditions
	, scope=wholeSubtree     % Search scope
	, deref=derefAlways      % Dereference
	, attributes = []        % Attributes to be returned
	, types_only = false     % Return types+values or types
	, timeout = 0            % Timelimit for search
	, async=false 			 % Async search (for persistent searching)
	}).

%%%
%%% Returned search result
%%%
-record(eldap_search_result,
	{ entries = []           % List of #eldap_entry{} records
	, referrals = []         % List of referrals
	}).

%%%
%%% LDAP entry
%%%
-record(eldap_entry,
	{ object_name = ""       % The DN for the entry
	, attributes = []        % List of {Attribute, Value} pairs
	}).
