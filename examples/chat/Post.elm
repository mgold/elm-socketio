module Post where

{-| A module to handle the text field to post messages. -}

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

type alias State = {content : Field.Content, submit : String}
state0 = State Field.noContent ""

stateMB : Signal.Mailbox State
stateMB = Signal.mailbox state0

field : Signal Element
field =
    let base = Field.field Field.defaultStyle
                   (\fc -> Signal.message stateMB.address (State fc "")) ""
    in Signal.map (.content>>base) stateMB.signal

submit : Signal Element
submit =
    Signal.map (\s -> Input.button
                      (Signal.message stateMB.address
                          <| State Field.noContent s.content.string)
                      "Submit")
               stateMB.signal

submitStates : Signal State
submitStates =
    Signal.filter (\s -> not <| String.isEmpty s.submit) state0 stateMB.signal

stateToMessage : State -> Message -> Time -> Message
stateToMessage {submit} {name, color} =
    Message "post" name submit color

submissions : Signal Message
submissions =
    Signal.map3 stateToMessage submitStates Login.submissions clock
        |> Signal.sampleOn submitStates

main : Signal Element
main =
    Signal.map2 E.beside field submit
   -- let render a b c = a `E.beside` b `E.beside` c
   -- in Signal.map3 render field submit (Signal.map E.show submissions)

