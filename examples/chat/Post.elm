module Post (main, submissions, submit) where

{-| A module to handle the text field to post messages. -}

import Graphics.Element as E exposing (Element)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Task exposing (Task, andThen)
import String
import Time exposing (Time)

import SocketIO
import Protocol exposing (..)
import Login
import Dispatch as Signal

type alias State = {submit : String, content : Field.Content}
state0 = State "" Field.noContent

states : Signal.Dispatcher State
states = Signal.dispatcher state0

field : Signal Element
field =
    let base = Field.field Field.defaultStyle
                   ((State "")>>states.dispatch) ""
    in Signal.map (.content>>base) states.signal

submitButton : Signal Element
submitButton =
    Signal.map (\s -> Input.button
                      (states.dispatch
                          <| State s.content.string Field.noContent)
                      "Send")
               states.signal

submitStates : Signal State
submitStates =
    Signal.filter (\s -> not <| String.isEmpty s.submit) state0 states.signal

stateToMessage : State -> Message -> Time -> Message
stateToMessage {submit} {name, color} =
    Message "post" name submit color

submissions : Signal Message
submissions =
    Signal.map3 stateToMessage submitStates Login.submissions clock
        |> Signal.sampleOn submitStates

main : Signal Element
main =
   let render a b = E.flow E.right [E.width 300 a, E.spacer 10 20, E.height 30 b]
                       `E.above` E.spacer 1 20
   in Signal.map2 render field submitButton

submit : Signal (Task x ())
submit =
     let send x = socket `andThen` SocketIO.emit eventName x
     in Signal.map (encodeMessage>>send) submissions
