module View where

import Graphics.Element as E exposing (Element)
import Time exposing (Time)
import Text exposing (Text)
import Date
import Color exposing (Color)

import Protocol exposing (..)

renderMessages : Int -> List Message -> Element
renderMessages mtw ms =
    E.flow E.up <| List.map (renderOne mtw) ms

renderOne : Int -> Message -> Element
renderOne mtw message =
    let elem = case message.method of
            "join" -> renderJoin message
            "post" -> renderPost message mtw
            "leave" -> renderLeave message
            _ -> E.empty
    in E.flow E.down [elem, E.spacer 1 20]

renderJoin {name, body, time, color} =
    let a = Text.fromString name |> Text.color color |> Text.bold
        b = Text.fromString " has joined the room. "
        c = renderTime time
        metadata = E.leftAligned (a++b++c)
        data = E.leftAligned <| Text.fromString <| "Quest: \"" ++ body ++ "\""
    in E.flow E.down [metadata, data]

renderPost {name, body, time, color} mtw =
    let a = Text.fromString name |> Text.color color |> Text.bold
        b = renderTime time
        metadata = E.leftAligned (a++b)
        enforceWidth el = E.width (min mtw (E.widthOf el)) el
        data = enforceWidth <| E.leftAligned <| Text.fromString body
        text = E.flow E.down [metadata, data]
        avatar = E.spacer 40 40 |> E.color color
    in E.flow E.right [avatar, E.spacer 5 1, text]

renderLeave {name, body, time, color} =
    let a = Text.fromString name |> Text.color color |> Text.bold
        b = Text.fromString " has left the room. "
        c = renderTime time
    in a++b++c |> E.leftAligned

renderTime : Time -> Text
renderTime time =
    let date = Date.fromTime time
        hour = toString <| Date.hour date
        minute = toString <| Date.minute date
    in Text.fromString ("  " ++ hour ++ ":" ++ minute) |> Text.color Color.lightCharcoal

bgColor : Color -> Color
bgColor c =
    if c == Color.blue then Color.lightBlue else
    if c == Color.red then Color.lightRed else
    if c == Color.green then Color.lightGreen else
    if c == Color.yellow then Color.lightYellow else
    if c == Color.purple then Color.lightPurple else
    if c == Color.orange then Color.lightOrange else
       Color.darkGray

render : (Int, Int) -> String -> Color -> List Message -> Element -> Element
render (w,h) name color messages post =
    let width = min w 500
        height = (max (toFloat h * 0.9 |> round) 600)
        maxTextWidth =  width - 60
    in E.flow E.down [(renderMessages maxTextWidth messages), E.spacer 1 5, post]
        |> E.container width height E.midBottom
        |> E.color Color.lightGray
        |> E.container w h E.middle
        |> E.color (bgColor color)

