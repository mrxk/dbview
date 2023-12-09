module Decoder exposing (..)

import Dict
import Json.Decode as Decode
import Json.Decode.Extra as Extra
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
                    Err { message = "Invalid JSON", severity = "", code = "" } |> Decode.succeed


jsonQueryDecoder : Decode.Decoder {text:String, watch:Bool}
jsonQueryDecoder =
    Field.attempt "text" Decode.string <| \maybeText ->
    Field.attempt "watch" Decode.bool <| \maybeWatch ->
    { text = Maybe.withDefault "failed" maybeText
    , watch = Maybe.withDefault False maybeWatch
    } |> Decode.succeed

queryTupleConstructor : Int -> {text:String, watch:Bool} -> (Int, Model.Query)
queryTupleConstructor i jsonQuery =
    let
        default = Model.emptyQuery
    in
        ( i, { default | text=jsonQuery.text, watch=jsonQuery.watch } )


modelDecoder : Decode.Decoder Model.Model
modelDecoder =
    Field.attempt "queries" (Decode.list jsonQueryDecoder) <| \maybeJSONQueries ->
    Field.attempt "nextId" Decode.int <| \maybeNextId ->
    Field.attempt "sleepTime" Decode.float <| \maybeSleepTime ->
    Field.attempt "wrap" Decode.bool <| \maybeWrap ->
    Field.attempt "showModel" Decode.bool <| \maybeShowModel ->

    let
        maybeJSONQueryTuples = Maybe.map (\l -> List.indexedMap queryTupleConstructor l) maybeJSONQueries
        maybeQueries = Maybe.map(\t -> Dict.fromList t) maybeJSONQueryTuples
    in
        { queries = Maybe.withDefault (Dict.singleton 0 Model.emptyQuery) maybeQueries
        , nextId = Maybe.withDefault 1 maybeNextId
        , sleepTime = Maybe.withDefault 1000 maybeSleepTime
        , wrap = Maybe.withDefault False maybeWrap
        , showModel = Maybe.withDefault False maybeShowModel
        , connectionString = ""
        , newModelJSON = ""
        } |> Decode.succeed


collectQueries : Int -> Model.Query -> List {text:String, watch:Bool} -> List {text:String, watch:Bool}
collectQueries _ query queries =
    {text=query.text, watch=query.watch} :: queries

modelEncoder : Model.Model -> Encode.Value
modelEncoder model =
    let
        queries = Dict.foldr collectQueries [] model.queries
    in
    Encode.object
        [ ("queries", Encode.list (\o -> Encode.object [("text", Encode.string o.text), ("watch", Encode.bool o.watch)])  queries)
        , ("sleepTime", Encode.float model.sleepTime)
        , ("wrap", Encode.bool model.wrap)
        ]
