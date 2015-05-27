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

import SocketIO

type alias State = {name : String, quest : String, color : Color}
type Delta = Name String | Quest String | AColor Color

deltas : Signal.Mailbox Delta
deltas = Signal.mailbox (Name "")

state : Signal State
state =
    let step delta oldState = case delta of
            Name name -> {oldState| name <- name}
            Quest quest -> {oldState| quest <- quest}
            AColor color -> {oldState| color <- color}
        state0 = State "" "" C.black
    in Signal.foldp step state0 deltas.signal

colors : Element
colors =
    Input.dropDown (\c -> Signal.message deltas.address (AColor c))
        [ ("Blue", C.blue)
        , ("Red", C.red)
        , ("Green", C.green)
        , ("Yellow", C.yellow)
        , ("Orange", C.orange)
        , ("Purple", C.purple)
        , ("Gray", C.gray)
        ] |> E.width 150

submission : Signal.Mailbox ()
submission = Signal.mailbox ()


submit : Element
submit =
    Input.button (Signal.message submission.address ()) "Submit"
        |> E.size 80 30

display : String -> Element
display s =
    Text.fromString s |> E.leftAligned

title : String -> Element
title s =
    Text.fromString s |> Text.height 24 |> Text.typeface ["avenir", "sane-serif"] |> E.centered

form : Element
form = E.flow E.down
    [ title "Elm Chat with SocketIO"
    , E.spacer 1 30
    , display "What is your name?"
    , display "[ name field    ]"
    , E.spacer 1 20
    , display "What is your quest?"
    , display "[ quest field   ]"
    , E.spacer 1 20
    , display "What is your favourite colour?"
    , colors
    , E.spacer 1 20
    , submit
    ] |> E.container 300 320 E.middle
      |> E.color C.lightGray

render (w,h) =
    E.color C.lightBlue <|
    E.container w h E.middle form

main =
    Signal.map render Window.dimensions

