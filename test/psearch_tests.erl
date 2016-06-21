-module(psearch_tests).
-compile([export_all]).
-include_lib("eunit/include/eunit.hrl").
-include("ELDAPv3.hrl").
-include("eldap.hrl").

first_test_() ->
    {timeout, 50000, fun first/0}.

log(_Level, FormatString, FormatArg) ->
    % ?debugFmt(FormatString, FormatArg),
    ok.

rcv() ->
    receive
        Msg -> Msg
    end.

first() ->
    {ok, HandleAsync} = eldap:open(["localhost"],
        [ {port, 10389}
        , {log, fun log/3}
        , {reply_to, self()}
        ]),
    {ok, Handle} = eldap:open(["localhost"],
        [ {port, 10389}
        , {log, fun log/3}
        ]),

    eldap:modify(Handle, "uid=yuri,ou=users,dc=example,dc=com",
        [eldap:mod_replace("sn", ["Noname"])]),

    Filter = eldap:present("cn"),
    Control = eldap:control(persistent_search,
        [ {change_types, [modify]}
        , {changes_only, true}
        , {return_ecs, false}
        ]),

    eldap:search(HandleAsync,
        [ {base, "dc=example,dc=com"}
        , {filter, Filter}
        , {attributes, ["sn", "cn"]}
        , {timeout, 10}
        , {async, true}
        ], [Control]),

    eldap:modify(Handle, "uid=yuri,ou=users,dc=example,dc=com",
        [eldap:mod_replace("sn", ["Artemev"])]),

    ?assertEqual({ldap,
        #'SearchResultEntry'{
            objectName = <<"uid=yuri,ou=users,dc=example,dc=com">>,
            attributes =
                [ {'PartialAttribute',<<"cn">>,[<<"Yuri">>]}
                , {'PartialAttribute',<<"sn">>,[<<"Artemev">>]}
                ]}}, rcv()).
