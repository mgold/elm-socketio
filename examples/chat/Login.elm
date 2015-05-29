module Login where

import Graphics.Element as E exposing (show, Element)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Task exposing (Task, andThen)
import Color as C exposing (Color)
import String
import Time exposing (Time)
import Text
import Debug
import Window
import Json.Encode as Encode
import Signal exposing ((<~), (~))

import SocketIO exposing (Socket)

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
    Input.dropDown (\c -> sendState (\s -> {s| color <- c}))
        [ ("Blue", C.blue)
        , ("Red", C.red)
        , ("Green", C.green)
        , ("Yellow", C.yellow)
        , ("Orange", C.orange)
        , ("Purple", C.purple)
        , ("Gray", C.gray)
        ] |> E.width 150

nameField =
    Field.field Field.defaultStyle
    (\fc -> sendState (\s -> {s|name <- fc}))
    "" <~ (Signal.map .name state)

questField =
    Field.field Field.defaultStyle
    (\fc -> sendState (\s -> {s|quest <- fc}))
    "" <~ (Signal.map .quest state)

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
    render <~ Window.dimensions ~ nameField ~ questField

submissions = Signal.sampleOn submitMB.signal state

submit : Task x Socket -> Signal (Task x ())
submit socket =
    let encode s = Encode.encode 0 <| Encode.object
            [ ("name", Encode.string (s.name.string))
            , ("quest", Encode.string (s.quest.string))
            , ("color", encodeColor (C.toRgb s.color)) ]
        encodeColor {red, green, blue, alpha} = Encode.object
            [ ("red", Encode.int red), ("green", Encode.int green),
              ("blue", Encode.int blue), ("alpha", Encode.float alpha)]
        send x = socket `andThen` SocketIO.emit "join" x
    in Signal.map (encode>>send) submissions

socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

port run : Signal (Task x ())
port run = submit socket
