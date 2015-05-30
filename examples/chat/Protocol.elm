module Protocol where
{-| A module encapsulating all protocol knowledge, as well as few other common functions. -}

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import Color exposing (Color)
import Time exposing (Time)
import Task exposing (Task)

import SocketIO

socket : Task x SocketIO.Socket
socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

eventName : String
eventName = "chat"

clock : Signal Time
clock = Time.every Time.second

type alias Message =
    { method : String
    , name : String
    , body : String
    , color : Color
    , time : Time
    }

decodeMessage : String -> Result String Message
decodeMessage =
    Decode.decodeString <| Decode.object5 Message
        ("method" := Decode.string)
        ("name" := Decode.string)
        ("body" := Decode.string)
        ("color" := decodeColor)
        ("time" := Decode.float)

encodeMessage : Message -> String
encodeMessage {method, name, body, color, time} =
    Encode.encode 0 <| Encode.object
        [ ("method", Encode.string method)
        , ("name", Encode.string name)
        , ("body", Encode.string body)
        , ("color", encodeColor color)
        , ("time", Encode.float time)
        ]

decodeColor : Decode.Decoder Color
decodeColor =
    Decode.object4 Color.rgba
        ("red" := Decode.int)
        ("green" := Decode.int)
        ("blue" := Decode.int)
        ("alpha" := Decode.float)

encodeColor : Color -> Encode.Value
encodeColor c =
    let {red, green, blue, alpha} = Color.toRgb c
    in Encode.object
        [ ("red", Encode.int red)
        , ("green", Encode.int green)
        , ("blue", Encode.int blue)
        , ("alpha", Encode.float alpha)
        ]
