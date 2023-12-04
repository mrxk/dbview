module Update exposing (..)

import Decoder
import Dict
import Http
import Json.Decode as Decode
import Json.Decode.Field as Field
import Json.Encode as Encode
import Model
import Process
import Task


update : Model.Msg -> Model.Model -> ( Model.Model, Cmd Model.Msg )
update msg model =
    case msg of
        Model.UpdateQueryText id text ->
            let
                maybeQuery =
                    Dict.get id model.queries
            in
            case maybeQuery of
                Just query ->
                    let
                        newQueries =
                            Dict.insert id { query | text = text } model.queries
                    in
                    ( { model | queries = newQueries }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Model.UpdateQueryWatch id watch ->
            let
                maybeQuery =
                    Dict.get id model.queries
            in
            case maybeQuery of
                Just query ->
                    let
                        newQueries =
                            Dict.insert id { query | watch = watch } model.queries
                    in
                    ( { model | queries = newQueries }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Model.UpdateQueryResult id httpResult ->
            let
                maybeQuery =
                    Dict.get id model.queries

                errorString =
                    parseErrorString httpResult
            in
            case maybeQuery of
                Just query ->
                    let
                        cmd =
                            if query.watch then
                                Process.sleep model.sleepTime |> Task.perform (always (Model.ExecuteQuery id))

                            else
                                Cmd.none

                        newQueries =
                            case httpResult of
                                Ok queryResult ->
                                    Dict.insert id { query | result = queryResult } model.queries

                                Err _ ->
                                    Dict.insert id { query | result = Err { message = errorString, severity = "", code = "" } } model.queries
                    in
                    ( { model | queries = newQueries }, cmd )

                Nothing ->
                    ( model, Cmd.none )

        Model.UpdateConnectionString httpResult ->
            let
                connectionString =
                    parseConnectionString httpResult
            in
            ( { model | connectionString = connectionString }, Cmd.none )

        Model.UpdateWrap wrap ->
            ( { model | wrap = wrap }, Cmd.none )

        Model.RemoveQuery id ->
            let
                maybeQuery =
                    Dict.get id model.queries
            in
            case maybeQuery of
                Just query ->
                    let
                        newQueries =
                            Dict.remove id model.queries
                    in
                    ( { model | queries = newQueries }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Model.AddQuery ->
            let
                newNextId =
                    model.nextId + 1

                newQueries =
                    Dict.insert model.nextId Model.emptyQuery model.queries
            in
            ( { model | nextId = newNextId, queries = newQueries }, Cmd.none )

        Model.ExecuteQuery id ->
            let
                maybeQuery =
                    Dict.get id model.queries
            in
            case maybeQuery of
                Just query ->
                    ( model, doQuery id query.text )

                Nothing ->
                    ( model, Cmd.none )

        Model.UpdateSleepTime timeString ->
            let
                newSleepTimeResult =
                    String.toFloat timeString
            in
            case newSleepTimeResult of
                Just newSleepTime ->
                    ( { model | sleepTime = newSleepTime }, Cmd.none )

                _ ->
                    ( { model | sleepTime = 1000 }, Cmd.none )


doQuery : Int -> String -> Cmd Model.Msg
doQuery id text =
    Http.post
        { url = "/postgres"
        , body = Http.jsonBody (Encode.object [ ( "query", Encode.string text ) ])
        , expect = Http.expectJson (Model.UpdateQueryResult id) Decoder.resultDecoder
        }


parseErrorString : Result Http.Error a -> String
parseErrorString result =
    case result of
        Err error ->
            case error of
                Http.BadUrl url ->
                    "bad url: " ++ url

                Http.Timeout ->
                    "timeout"

                Http.NetworkError ->
                    "network error"

                Http.BadStatus status ->
                    "bad status: " ++ String.fromInt status

                Http.BadBody body ->
                    "bad body: " ++ body

        Ok value ->
            ""


parseConnectionString : Result Http.Error String -> String
parseConnectionString result =
    case result of
        Err error ->
            case error of
                Http.BadUrl url ->
                    "bad url: " ++ url

                Http.Timeout ->
                    "timeout"

                Http.NetworkError ->
                    "network error"

                Http.BadStatus status ->
                    "bad status: " ++ String.fromInt status

                Http.BadBody body ->
                    "bad body: " ++ body

        Ok value ->
            value
