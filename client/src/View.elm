module View exposing (..)

import Decoder
import Dict
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Encode as Encode
import Model


view : Model.Model -> Html.Html Model.Msg
view model =
    Html.div [] [ viewBody model ]


viewBody : Model.Model -> Html.Html Model.Msg
viewBody model =
    Html.div []
        [ Html.div [ Attributes.class "modelButton", Events.onClick (Model.UpdateShowModel True) ] [ Html.text "model" ]
        , Html.br [] []
        , Html.h1 [ Attributes.class "title" ] [ Html.text "DBView" ]
        , Html.div [ Attributes.class "subtitle" ] [ Html.text model.connectionString ]
        , Html.div [ Attributes.class "content" ] (Dict.map (viewQuery model) model.queries |> Dict.values)
        , Html.input [ Attributes.id "wrapCheckbox", Attributes.class "wrapCheckbox", Attributes.type_ "checkbox", Attributes.checked model.wrap, Events.onCheck Model.UpdateWrap ] []
        , Html.label [ Attributes.for "wrapCheckbox", Attributes.class "wrapLabel" ] [ Html.text "wrap" ]
        , Html.br [] []
        , Html.text "sleep time (ms):"
        , Html.input [ Attributes.id "sleepTime", Attributes.class "sleepInput", Attributes.value (String.fromFloat model.sleepTime), Events.onInput Model.UpdateSleepTime ] []
        , Html.br [] []
        , Html.button [ Attributes.id "add", Attributes.class "addQueryButton", Events.onClick Model.AddQuery ] [ Html.text "add" ]
        , viewModelDialog model
        ]


viewQuery : Model.Model -> Int -> Model.Query -> Html.Html Model.Msg
viewQuery model id query =
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
            [ viewQueryResult model query.result
            ]
        ]


viewQueryResult : Model.Model -> Result Model.QueryError Model.QueryResult -> Html.Html Model.Msg
viewQueryResult model result =
    case result of
        Err error ->
            Html.pre [] [ Html.text (error.message ++ "\n" ++ error.severity ++ " " ++ error.code) ]

        Ok success ->
            let
                class =
                    if model.wrap then
                        "wrap"

                    else
                        "nowrap"
            in
            Html.div []
                [ Html.text (String.fromInt success.count)
                , Html.table [ Attributes.class class ]
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


viewModelDialog : Model.Model -> Html.Html Model.Msg
viewModelDialog model =
    if model.showModel then
        Html.div [ Attributes.class "dialogContainer" ]
            [ Html.node "dialog"
                [ Attributes.class "dialog", Attributes.attribute "open" "" ]
                [ Html.textarea [ Attributes.class "modelInput", Events.onInput Model.UpdateNewModelJSON ]
                    [ Html.text model.newModelJSON
                    ]
                , Html.br [] []
                , Html.button [ Attributes.class "modelOk", Events.onClick Model.ApplyNewModelJSON ] [ Html.text "OK" ]
                , Html.button [ Attributes.class "modelCancel", Events.onClick (Model.UpdateShowModel False) ] [ Html.text "Cancel" ]
                ]
            ]

    else
        Html.div [ Attributes.class "dialog" ] []
