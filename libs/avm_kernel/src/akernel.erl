-module(akernel).

-export([start/0]).

start() ->
    io:format("Starting AtomVM Kernel module.~n"),
    network_console:listen(2323),
    try_start_ap(),
    Sections = atomvm:all_avmpack_sections([start]),
    start_all(Sections),
    sleep_forever().

start_all([]) ->
    [];
start_all([BEAMName | T]) ->
    [ModuleName, <<"">>] = binary:split(BEAMName, <<".beam">>),
    Module = erlang:binary_to_atom(ModuleName, latin1),
    case Module of
        ?MODULE -> ok;
        StartModule ->
            io:format("Starting ~p~n.", [Module]),
            spawn(StartModule, start, [])
    end,
    start_all(T).

sleep_forever() ->
    timer:sleep(10000),
    sleep_forever().

try_start_ap() ->
    try start_ap() of
        Any -> Any
    catch
        _:_ ->
            io:format("Failed STA configuration.~n")
    end.

start_ap() ->
    Config = [
        {ap, [
            %% If an SSID is not specified, AtomVM will default to atomvm-<hexmac>
            %% where <hexmac> is the hexadecimal representation of the factory-supplied
            %% MAC address of the ESP32 device.
            %% {ssid, esp:nvs_get_binary(atomvm, ap_ssid, <<"myssid">>)},
            %% If a password is not specified, the AP network will be open, with
            %% no encryption or authentication (strongly discouraged)
            %% {psk,  esp:nvs_get_binary(atomvm, ap_psk, <<"mypsk">>)},
            {ap_started, fun ap_started/0},
            {sta_connected, fun sta_connected/1},
            {sta_ip_assigned, fun sta_ip_assigned/1},
            {sta_disconnected, fun sta_disconnected/1}
        ]}
    ],
    case network_fsm:start(Config) of
        ok -> ok;
        Error -> erlang:display(Error)
    end.

ap_started() ->
    io:format("AP started.~n").

sta_connected(Mac) ->
    io:format("STA connected with mac ~p~n", [Mac]).

sta_disconnected(Mac) ->
    io:format("STA disconnected with mac ~p~n", [Mac]).

sta_ip_assigned(Address) ->
    io:format("STA assigned address ~p~n", [Address]).
