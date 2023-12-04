module Decoder exposing (..)

import Debug
import Json.Decode as Decode
import Json.Decode.Field as Field
import Json.Encode as Encode
import Model

resultDecoder : Decode.Decoder (Result Model.QueryError Model.QueryResult)
resultDecoder =
    Field.attempt "message" Decode.string <| \maybeMessage ->
    Field.attempt "severity" Decode.string <| \maybeSeverity ->
    Field.attempt "code" Decode.string <| \maybeCode ->
    Field.attempt "count" Decode.int <| \maybeCount ->
    Field.attempt "columns" (Decode.list Decode.string) <| \maybeColumns ->
    Field.attempt "rows" (Decode.list (Decode.list  
        (Decode.oneOf
            [ Decode.string
            , Decode.null ""
            , Decode.map String.fromInt (Decode.int)
            , Decode.map String.fromFloat (Decode.float)
            ]
        )
    )) <| \maybeRows ->

    case maybeCount of
        Just count ->
            case ( maybeColumns, maybeRows ) of
                ( Just columns, Just rows ) ->
                    Ok { count = count, columns = columns, rows = rows } |> Decode.succeed
                _ ->
                    Ok { count = count, columns = [], rows = [[]] } |> Decode.succeed

        _ ->
            case ( maybeMessage, maybeSeverity, maybeCode ) of
                ( Just message, Just severity, Just code ) ->
                    Err { message = message, severity = severity, code = code } |> Decode.succeed

                _ ->
                    let
                        _ = Debug.log "maybeSeverity" maybeSeverity
                        _ = Debug.log "maybeCode" maybeCode
                        _ = Debug.log "maybeColumns" maybeColumns
                        _ = Debug.log "maybeRows" maybeRows
                    in
                    Err { message = "Invalid JSON", severity = "", code = "" } |> Decode.succeed
