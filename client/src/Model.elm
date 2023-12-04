module Model exposing (..)

import Dict
import Http


type alias QueryError =
    { message : String
    , severity : String
    , code : String
    }


type alias QueryResult =
    { count : Int
    , columns : List String
    , rows : List (List String)
    }


type alias Query =
    { text : String
    , result : Result QueryError QueryResult
    , watch : Bool
    }


type alias Model =
    { queries : Dict.Dict Int Query
    , nextId : Int
    , sleepTime : Float
    }


emptyQuery : Query
emptyQuery =
    { text = ""
    , watch = False
    , result = Ok { count = 0, columns = [], rows = [ [] ] }
    }


emptyModel : Model
emptyModel =
    { queries = Dict.singleton 0 emptyQuery
    , nextId = 1
    , sleepTime = 1000
    }


type Msg
    = AddQuery
    | RemoveQuery Int
    | UpdateQueryWatch Int Bool
    | UpdateQueryText Int String
    | UpdateQueryResult Int (Result Http.Error (Result QueryError QueryResult))
    | ExecuteQuery Int
    | UpdateSleepTime String
