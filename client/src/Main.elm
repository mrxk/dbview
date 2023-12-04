module Main exposing (..)

import Browser
import Dict
import Http
import Model
import Update
import View


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = Update.update
        , view = View.view
        }


init : Maybe String -> ( Model.Model, Cmd Model.Msg )
init _ =
    ( Model.emptyModel
    , Http.get
        { url = "/connectionString"
        , expect = Http.expectString Model.UpdateConnectionString
        }
    )


subscriptions : Model.Model -> Sub Model.Msg
subscriptions _ =
    Sub.none
