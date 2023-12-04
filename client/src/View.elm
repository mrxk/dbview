module View exposing (..)

import Dict
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model


view : Model.Model -> Html.Html Model.Msg
view model =
    Html.div [] [ viewBody model ]


viewBody : Model.Model -> Html.Html Model.Msg
viewBody model =
    Html.div []
        [ Html.h1 [ Attributes.class "title" ] [ Html.text "DBView" ]
        , Html.div [ Attributes.class "content" ] (Dict.map viewQuery model.queries |> Dict.values)
        , Html.text "sleep time (ms):"
        , Html.input [ Attributes.id "sleepTime", Attributes.class "sleepInput", Attributes.value (String.fromFloat model.sleepTime), Events.onInput Model.UpdateSleepTime ] []
        , Html.br [] []
        , Html.button [ Attributes.id "add", Attributes.class "addQueryButton", Events.onClick Model.AddQuery ] [ Html.text "add" ]
        ]


viewQuery : Int -> Model.Query -> Html.Html Model.Msg
viewQuery id query =
    let
        htmlId =
            "query" ++ String.fromInt id
    in
    Html.div [ Attributes.id htmlId, Attributes.class "queryContainer" ]
        [ Html.div [ Attributes.id ("close_" ++ htmlId), Attributes.class "closeButton", Events.onClick (Model.RemoveQuery id) ] [ Html.text "x" ]
        , Html.textarea [ Attributes.id ("text_" ++ htmlId), Attributes.class "queryInput", Attributes.value query.text, Events.onInput (Model.UpdateQueryText id) ] []
        , Html.button [ Attributes.id ("execute_" ++ htmlId), Attributes.class "executeButton", Events.onClick (Model.ExecuteQuery id) ] [ Html.text "execute" ]
        , Html.input [ Attributes.id ("watch_" ++ htmlId), Attributes.class "watchCheckbox", Attributes.type_ "checkbox", Attributes.checked query.watch, Events.onCheck (Model.UpdateQueryWatch id) ] []
        , Html.label [ Attributes.for ("watch_" ++ htmlId), Attributes.class "watchLabel" ] [ Html.text "watch" ]
        , Html.div [ Attributes.id ("output_" ++ htmlId), Attributes.class "output" ]
            [ viewQueryResult query.result
            ]
        ]


viewQueryResult : Result Model.QueryError Model.QueryResult -> Html.Html Model.Msg
viewQueryResult result =
    case result of
        Err error ->
            Html.pre [] [ Html.text (error.message ++ "\n" ++ error.severity ++ " " ++ error.code) ]

        Ok success ->
            Html.div []
                --Html.text (String.fromInt success.count)
                [ Html.table []
                    (viewQueryResultHeaderRow success.columns
                        :: List.map viewQueryResultDataRow success.rows
                    )
                ]


viewQueryResultHeaderRow : List String -> Html.Html Model.Msg
viewQueryResultHeaderRow headers =
    Html.tr [] (List.map (\v -> Html.th [] [ Html.text v ]) headers)


viewQueryResultDataRow : List String -> Html.Html Model.Msg
viewQueryResultDataRow values =
    Html.tr [] (List.map (\v -> Html.td [] [ Html.text v ]) values)
