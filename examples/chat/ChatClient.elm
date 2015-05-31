module ChatClient where

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
import Post

port outgoingJoins : Signal (Task x ())
port outgoingJoins = Login.submit
port outgoingPosts : Signal (Task x ())
port outgoingPosts = Post.submit

receivingMB : Signal.Mailbox String
receivingMB = Signal.mailbox "null"

port responses : Task x ()
port responses = socket `andThen` SocketIO.on eventName receivingMB.address

messages : Signal (List Message)
messages =
    Signal.map (decodeMessage>>Result.toMaybe) receivingMB.signal
    |> Signal.merge (Signal.map Just Post.submissions)
    |> Signal.foldp (\mx xs -> case mx of
        Just x -> x::xs
        Nothing -> xs) []


{---- View ----}
renderMessages : List Message -> Element
renderMessages ms =
    E.flow E.up <| List.map renderOne ms

renderOne : Message -> Element
renderOne {name, body, time} =
    let message = String.join " - " [name, body, toString time]
    in Text.fromString message |> E.leftAligned

renderedMessages : Signal Element
renderedMessages =
    Signal.map renderMessages messages

type alias ViewComponents = {login : Element, post : Element, messages : Element}
viewComponents : Signal ViewComponents
viewComponents = Signal.map3 ViewComponents Login.main Post.main renderedMessages

render : Message -> ViewComponents -> Element
render {name, color} {login, post, messages} =
    if String.isEmpty name then login
    else E.flow E.down [messages, post]

main : Signal Element
main =
    Signal.map2 render Login.submissions viewComponents


