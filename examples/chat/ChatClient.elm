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
import Color exposing (Color)
import Debug

import SocketIO
import Protocol exposing (..)
import Login

port loginTask : Signal (Task x ())
port loginTask = Login.submit

receiving : Signal.Mailbox String
receiving = Signal.mailbox "null"

-- Send server data to the mailbox
port responses : Task x ()
port responses = socket `andThen` SocketIO.on eventName receiving.address

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
    in Message "Chat Client" msg t Color.blue submit

localMessage : Signal Message
localMessage =
    Signal.map2 fieldModelToMessage (clock |> Signal.sampleOn entries.signal) entries.signal

port outgoing : Signal (Task x ())
port outgoing =
    let send x = socket `andThen` SocketIO.emit eventName x
    in Signal.map (encodeMessage>>send) localMessage


messages : Signal (List Message)
messages =
    Signal.map (decodeMessage>>Result.toMaybe) receiving.signal
    |> Signal.merge (Signal.map (\m -> if m.submit then Just m else Nothing) localMessage)
    |> Signal.foldp (\mx xs -> case mx of
        Just x -> x::xs
        Nothing -> xs) []

{---- View ----}
render : Element -> Time -> List Message -> Element
render elem t ms =
    elem :: List.map (renderOne t) ms
        |> E.flow E.up

renderOne : Time -> Message -> Element
renderOne t {name, body, time} =
    let dt = t - time |> Time.inSeconds |> round
        timeMessage = if dt < 2 then "Just now" else toString dt ++ " seconds ago"
        message = String.join " - " [name, body, timeMessage]
    in Text.fromString message |> E.leftAligned

main : Signal Element
main =
    let textField = Signal.map2 E.beside field submit
    in Signal.map3 render textField (Time.every Time.second) messages |> Signal.sampleOn messages

