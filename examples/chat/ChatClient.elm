module Example where

import Graphics.Element as E exposing (show, Element)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Task exposing (Task, andThen)
import String
import Time exposing (Time)
import Text
import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import Debug

import SocketIO

{---- Client-Server Protocol ----}
eventName = "chat"

type alias Message =
    { name : String
    , body : String
    , time : Float
    , submit : Bool
    }

decode : String -> Result String Message
decode =
    Decode.decodeString <| Decode.object4 Message
        ("name" := Decode.string)
        ("body" := Decode.string)
        ("time" := Decode.float)
        ("submit" := Decode.bool)

encode : Message -> String
encode {name, body, time, submit} =
    Encode.object [ ("name", Encode.string name)
                  , ("body", Encode.string body)
                  , ("time", Encode.float time)
                  , ("submit", Encode.bool submit)
                  ]
        |> Encode.encode 0

{---- Received from Server ----}
socket : Task x SocketIO.Socket
socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

received : Signal.Mailbox String
received = Signal.mailbox "null"

-- Send server data to the mailbox
port responses : Task x ()
port responses = socket `andThen` SocketIO.on eventName received.address

-- Process incoming JSON into something useful
messages : Signal (List Message)
messages =
    Signal.map (decode>>Result.toMaybe) received.signal
    |> Signal.foldp (\mx xs -> case mx of
        Just x -> x::xs
        Nothing -> xs) []

{---- Sent to Server ----}
type alias FieldModel = {content : Field.Content, submit : Bool}
model0 = FieldModel Field.noContent False

entries : Signal.Mailbox FieldModel
entries = Signal.mailbox model0

field : Signal Element
field =
    let base = Field.field Field.defaultStyle (\c -> Signal.message entries.address (FieldModel c False)) ""
    in Signal.map (.content>>base) entries.signal

submit : Signal Element
submit =
    Signal.map (\{content} -> Input.button (Signal.message entries.address <| FieldModel content True) "Submit")
        entries.signal

port clearFieldAfterSubmit : Signal (Task x ())
port clearFieldAfterSubmit =
    Signal.filter .submit model0 entries.signal
        |> Signal.map (always <| Signal.send entries.address model0)

fieldModelToMessage : Time -> FieldModel -> Message
fieldModelToMessage t {content, submit} =
    let msg = if submit || String.isEmpty content.string then content.string else "x" -- don't send unsent typing
    in Message "Chat Client" msg t submit

clock : Signal Time
clock = Time.every Time.second

port outgoing : Signal (Task x ())
port outgoing =
    let send x = socket `andThen` SocketIO.emit eventName x
    in Signal.map2 (\fm t -> (fieldModelToMessage t fm) |> encode |> send)
        entries.signal (clock |> Signal.sampleOn entries.signal)

{---- View ----}
render : Time -> List Message -> Element
render t ms =
    List.map (renderOne t) ms
        |> E.flow E.up

renderOne : Time -> Message -> Element
renderOne t {name, body, time} =
    let dt = t - time |> Time.inSeconds |> round
        timeMessage = if dt < 2 then "Just now" else toString dt ++ " seconds ago"
        message = String.join " - " [name, body, timeMessage]
    in Text.fromString message |> E.leftAligned

main : Signal Element
main =
    Signal.map2 E.beside field submit
    --Signal.map3 render field (Time.every Time.second) messages |> Signal.sampleOn messages

