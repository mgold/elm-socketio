module Login (main, submissions, submit)  where

import Graphics.Element as E exposing (Element)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Task exposing (Task, andThen)
import Color as C exposing (Color)
import Time exposing (Time)
import Text
import Window
import Signal

import SocketIO exposing (Socket)
import Protocol exposing (..)

type alias State = {name : Field.Content, quest : Field.Content, color : Color}
stateMB : Signal.Mailbox (State -> State)
stateMB = Signal.mailbox identity
sendState = Signal.message stateMB.address

state : Signal State
state =
    let state0 = State Field.noContent Field.noContent C.blue
    in Signal.foldp (<|) state0 stateMB.signal

colors : Element
colors =
    Input.dropDown (\c -> sendState (\s -> {s| color = c}))
        [ ("Blue", C.blue)
        , ("Red", C.red)
        , ("Green", C.green)
        , ("Yellow", C.yellow)
        , ("Orange", C.orange)
        , ("Purple", C.purple)
        , ("Gray", C.charcoal)
        ] |> E.width 150

nameField =
    let
      fieldFunc =
        Field.field Field.defaultStyle
        (\fc -> sendState (\s -> {s|name = fc}))
        ""
      name = Signal.map .name state
    in
      Signal.map fieldFunc name

questField =
    let
      fieldFunc =
        Field.field Field.defaultStyle
        (\fc -> sendState (\s -> {s|quest = fc}))
        ""
      quest = Signal.map .quest state
    in
      Signal.map fieldFunc quest

submitMB = Signal.mailbox ()
submitButton =
    Input.button (Signal.message submitMB.address ()) "Submit"
        |> E.size 80 30

display : String -> Element
display s =
    Text.fromString s |> E.leftAligned

title : String -> Element
title s =
    Text.fromString s |> Text.height 24 |> Text.typeface ["avenir", "sane-serif"] |> E.centered

form : Element -> Element -> Element
form name quest = E.flow E.down
    [ title "Elm Chat with SocketIO"
    , E.spacer 1 30
    , display "What is your name?"
    , E.width 260 name
    , E.spacer 1 20
    , display "What is your quest?"
    , E.width 260 quest
    , E.spacer 1 20
    , display "What is your favourite colour?"
    , colors
    , E.spacer 1 20
    , submitButton
    ] |> E.container 300 320 E.middle
      |> E.color C.lightGray

render : (Int, Int) -> Element -> Element -> Element
render (w,h) name quest =
    E.container w h E.middle (form name quest)
    |> E.color C.lightBlue

main =
    Signal.map3 render Window.dimensions nameField questField

stateToMessage : State -> Time -> Message
stateToMessage s =
    Message "join" s.name.string s.quest.string s.color

submissions : Signal Message
submissions =
    Signal.map2 stateToMessage state clock
    |> Signal.sampleOn submitMB.signal

submit : Signal (Task x ())
submit =
    let send x = socket `andThen` SocketIO.emit eventName x
    in Signal.map (encodeMessage>>send) submissions
