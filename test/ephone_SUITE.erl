%%%-------------------------------------------------------------------
%%% @author Juan Jose Comellas <juanjo@comellas.org>
%%% @author Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>
%%% @author Paul Oliver <puzza007@gmail.com>
%%% @copyright (C) 2012 Juan Jose Comellas, Mahesh Paolini-Subramanya,
%%%                     Paul Oliver
%%% @doc
%%% Test suite for ephone
%%% @end
%%%-------------------------------------------------------------------
-module(ephone_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

suite() ->
    [{ct_hooks, [cth_surefire]}, {timetrap,{seconds,120}}].

init_per_suite(Config) ->
    start_applications(),
    start_server(Config),
    Config.


end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, _Config) ->
    ok.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

groups() ->
    [
        {common, [parallel],
         [t_clean_phone_number_1,
          t_clean_phone_number_2,
          t_clean_phone_number_3,
          t_clean_phone_number_4,
          t_clean_phone_number_5,
          t_clean_phone_number_6,
          t_normalize_did_invalid]},
        {us, [parallel],
         [t_normalize_did_us_domestic,
          t_normalize_did_us_domestic_formatted,
          t_parse_did_us_domestic,
          t_parse_did_us_domestic_formatted,
          t_parse_did_us_international_formatted,
          t_parse_did_us_canonical,
          t_parse_destination_us_local,
          t_parse_destination_us_local_formatted,
          t_parse_destination_us_toll_free,
          t_parse_destination_us_toll_free_formatted,
          t_parse_destination_us_international_canada,
          t_parse_destination_us_international_caribbean,
          t_parse_destination_us_domestic,
          t_parse_destination_us_domestic_10_digit,
          t_parse_destination_us_domestic_collect,
          t_parse_destination_us_emergency,
          t_parse_destination_us_international_premium,
          t_parse_destination_us_international,
          t_parse_did_us_domestic_with_extension_1,
          t_parse_did_us_domestic_with_extension_2,
          t_parse_did_us_domestic_with_extension_3,
          t_parse_did_us_domestic_with_extension_4,
          t_parse_did_us_domestic_with_extension_5,
          t_parse_did_us_domestic_with_extension_6,
          t_parse_did_us_domestic_with_extension_7,
          t_parse_did_us_domestic_with_extension_8]}
    ].

all() ->
    [{group, common},
     {group, us}].


t_clean_phone_number_1(_) ->
    <<"16502530000">> = ephone:clean_phone_number(<<"16502530000">>).

t_clean_phone_number_2(_) ->
    <<"16502530000">> = ephone:clean_phone_number(<<"+16502530000">>).

t_clean_phone_number_3(_) ->
    <<"16502530000">> = ephone:clean_phone_number(<<"+1 (650) 253-0000">>).

t_clean_phone_number_4(_) ->
    <<"16502530000">> = ephone:clean_phone_number(<<"+1 (650) 253-0000 x101">>).

t_clean_phone_number_5(_) ->
    <<"16502530000">> = ephone:clean_phone_number(<<"+1 (650) 253-0000 ext. 101">>).

t_clean_phone_number_6(_) ->
    <<>> = ephone:clean_phone_number(<<"ABCDEFGH">>).

t_normalize_did_invalid(_) ->
    {error, {invalid_did, <<"ABCDE">>}} = ephone:normalize_did(<<"ABCDE">>, [{country_code, <<"1">>}]).


t_normalize_did_us_domestic(_) ->
    {ok, <<"+16502530000">>} = ephone:normalize_did(<<"6502530000">>, [{country_code, <<"1">>}]).

t_normalize_did_us_domestic_formatted(_) ->
    {ok, <<"+16502530000">>} = ephone:normalize_did(<<"(650) 253-0000">>, [{country_code, <<"1">>}]).

t_parse_did_us_domestic(_) ->
    check_parse_did(<<"6502530000">>, <<"1">>, <<"6502530000">>).

t_parse_did_us_domestic_formatted(_) ->
    check_parse_did(<<"(650) 253-0000">>, <<"1">>, <<"6502530000">>).

t_parse_did_us_international_formatted(_) ->
    check_parse_did(<<"+1 (650) 253-0000">>, <<"1">>, <<"6502530000">>).

t_parse_did_us_canonical(_) ->
    check_parse_did(<<"+16502530000">>, <<"1">>, <<"6502530000">>).

t_parse_destination_us_local(_) ->
    check_parse_destination(<<"2530000">>, <<"us">>, <<"2530000">>, [local]).

t_parse_destination_us_local_formatted(_) ->
    check_parse_destination(<<"253-0000">>, <<"us">>, <<"2530000">>, [local]).

t_parse_destination_us_toll_free(_) ->
    check_parse_destination(<<"18006984637">>, <<"us">>, <<"18006984637">>, [toll_free]).

t_parse_destination_us_toll_free_formatted(_) ->
    check_parse_destination(<<"1‑800‑698‑4637">>, <<"us">>, <<"18006984637">>, [toll_free]).

t_parse_destination_us_international_canada(_) ->
    check_parse_destination(<<"1-613-231-2020">>, <<"us">>, <<"16132312020">>, [international]).

t_parse_destination_us_international_caribbean(_) ->
    check_parse_destination(<<"(876) 702-6000">>, <<"us">>, <<"8767026000">>, [international]).

t_parse_destination_us_domestic(_) ->
    check_parse_destination(<<"1 (650) 253-0000">>, <<"us">>, <<"16502530000">>, [domestic]).

t_parse_destination_us_domestic_10_digit(_) ->
    check_parse_destination(<<"(650) 253-0000">>, <<"us">>, <<"6502530000">>, [domestic]).

t_parse_destination_us_domestic_collect(_) ->
    check_parse_destination(<<"0-650-253-0000">>, <<"us">>, <<"06502530000">>, [domestic, collect]).

t_parse_destination_us_emergency(_) ->
    check_parse_destination(<<"911">>, <<"us">>, <<"911">>, [emergency]).

t_parse_destination_us_international_premium(_) ->
    check_parse_destination(<<"011 423 239 63 63">>, <<"us">>, <<"0114232396363">>, [international, premium]).

t_parse_destination_us_international(_) ->
    check_parse_destination(<<"011 (54) 11-4344-3600">>, <<"us">>, <<"011541143443600">>, [international]).

t_parse_destination_us_premium(_) ->
    check_parse_destination(<<"900-622-8000">>, <<"us">>, <<"9006228000">>, [premium]).

t_parse_destination_us_operator(_) ->
    check_parse_destination(<<"0">>, <<"us">>, <<"0">>, [operator]).

t_parse_destination_us_international_operator(_) ->
    check_parse_destination(<<"00">>, <<"us">>, <<"00">>, [international, operator]).

t_parse_did_us_domestic_with_extension_1(_) ->
    check_parse_did_with_extension(<<"(234)567-8901 x123">>, <<"1">>, <<"2345678901">>, <<"123">>).

t_parse_did_us_domestic_with_extension_2(_) ->
    check_parse_did_with_extension(<<"+1 (234)567-8901 x123">>, <<"1">>, <<"2345678901">>, <<"123">>).

t_parse_did_us_domestic_with_extension_3(_) ->
    check_parse_did_with_extension(<<"12 3456 789 01 x1234">>, <<"1">>, <<"2345678901">>, <<"1234">>).

t_parse_did_us_domestic_with_extension_4(_) ->
    check_parse_did_with_extension(<<"(234)567-8901x12">>, <<"1">>, <<"2345678901">>, <<"12">>).

t_parse_did_us_domestic_with_extension_5(_) ->
    check_parse_did_with_extension(<<"(234)567-8901ext12345">>, <<"1">>, <<"2345678901">>, <<"12345">>).

t_parse_did_us_domestic_with_extension_6(_) ->
    check_parse_did_with_extension(<<"(234)567-8901 extension12345">>, <<"1">>, <<"2345678901">>, <<"12345">>).

t_parse_did_us_domestic_with_extension_7(_) ->
    check_parse_did_with_extension(<<"234.567.8901 #12">>, <<"1">>, <<"2345678901">>, <<"12">>).

t_parse_did_us_domestic_with_extension_8(_) ->
    check_parse_did_with_extension(<<"1-234-567-8901 ext. 123">>, <<"1">>, <<"2345678901">>, <<"123">>).


%
%  INTERNAL
%

%% Initialization
start_applications() ->
    application:start(sasl),
    application:start(trie),
    application:start(kvc),
    application:start(jsx),
    application:start(ephone).

start_server(Config) ->
    setup_environment(Config).

setup_environment(_Config) ->
    application:set_env(ephone, default_iso_code, <<"us">>).

check_parse_did(Did, CountryCode, PhoneNumber) ->
    {ok, ParsedDid} = ephone:parse_did(Did, [{country_code, CountryCode}]),
    {country_code, CountryCode} = lists:keyfind(country_code, 1, ParsedDid),
    {phone_number, PhoneNumber} = lists:keyfind(phone_number, 1, ParsedDid).

check_parse_did_with_extension(Did, CountryCode, PhoneNumber, Extension) ->
    {ok, ParsedDid} = ephone:parse_did(Did, [{country_code, CountryCode}]),
    {country_code, CountryCode} = lists:keyfind(country_code, 1, ParsedDid),
    {phone_number, PhoneNumber} = lists:keyfind(phone_number, 1, ParsedDid),
    {extension, Extension} = lists:keyfind(extension, 1, ParsedDid).

check_parse_destination(Destination, IsoCode, PhoneNumber, BillingTags) ->
    {ok, ParsedDestination} = ephone:parse_destination(Destination, [{iso_code, <<"us">>}]),
    {phone_number, PhoneNumber} = lists:keyfind(phone_number, 1, ParsedDestination),
    {billing_tags, BillingTags} = lists:keyfind(billing_tags, 1, ParsedDestination).
