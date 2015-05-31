module ChatClient where

import Graphics.Element as E exposing (Element)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Task exposing (Task, andThen)
import String
import Color exposing (Color)
import Window

import SocketIO

import Protocol exposing (..)
import Login
import Post
import View

-- run tasks from other modules
port outgoingJoins : Signal (Task x ())
port outgoingJoins = Login.submit
port outgoingPosts : Signal (Task x ())
port outgoingPosts = Post.submit

-- receive messages
receivingMB : Signal.Mailbox String
receivingMB = Signal.mailbox "null"

port responses : Task x ()
port responses = socket `andThen` SocketIO.on eventName receivingMB.address

messages : Signal (List Message)
messages =
    Signal.map (decodeMessage>>Result.toMaybe) receivingMB.signal
    |> Signal.merge (Signal.map Just Post.submissions)
    |> Signal.dropRepeats
    |> Signal.foldp (\mx xs -> case mx of
        Just x -> x::xs
        Nothing -> xs) []

-- render view
type alias ViewComponents = {login : Element, post : Element}
viewComponents : Signal ViewComponents
viewComponents = Signal.map2 ViewComponents Login.main Post.main

render : (Int, Int) -> Message -> ViewComponents -> List Message -> Element
render dims {name, color} {login, post} messages =
    if String.isEmpty name then login
    else View.render dims name color messages post

main : Signal Element
main =
    Signal.map4 render Window.dimensions Login.submissions viewComponents messages


