module ExampleTEA where

{-| This module is the Numbers example using The Elm Architecture.
-}

import Signal exposing (Mailbox, Address)
import Task exposing (Task, andThen)
import String
import Time

import Html exposing (Html)
import Effects exposing (Never, Effects)
import StartApp
import SocketIO

type alias Socket = Task Never SocketIO.Socket
type alias Model = Int
type Action = NoOp | Received Int

eventName = "example"

-- task that gets you the socket, that either already exists or it makes one
socket : Socket
socket =
  SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

init : (Model, Effects Action)
init =
  let initialCount = 1
      task = socket
             `andThen` (\sock ->
               -- nested tasks are a silly trick to reuse the socket argument
               SocketIO.emit eventName (toString initialCount) sock -- first send
                                  -- received events go to the mailbox
                 `andThen` always (SocketIO.on eventName mailbox.address sock))
             |> Task.map (always NoOp)
             |> Effects.task
  in (initialCount, task)

update : Action -> Model -> (Model, Effects Action)
update action count =
  case action of
    NoOp -> (count, Effects.none)
    Received newCount -> (newCount, send (newCount+1))

send : Model -> Effects Action
send count =
  Task.sleep Time.second
    `andThen` always socket
    `andThen` SocketIO.emit eventName (toString count)
    |> Task.map (always NoOp)
    |> Effects.task

-- This is the part where things get un-start-app-y
mailbox : Mailbox String
mailbox = Signal.mailbox ""

stringToAction : String -> Action
stringToAction i =
  case String.toInt i of
    Ok j -> Received j
    Err _ -> NoOp

inputs : List (Signal Action)
inputs = [Signal.map stringToAction mailbox.signal]
-- end un-start-app-y part

view : Address Action -> Model -> Html
view _ count = Html.p [] [Html.text (toString count)]

app : StartApp.App Model
app = StartApp.start { init = init, view = view, update = update, inputs = inputs }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
