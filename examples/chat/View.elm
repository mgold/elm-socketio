module View where

import Graphics.Element as E exposing (show, Element)
import String
import Time exposing (Time)
import Text
import Color exposing (Color)

import Protocol exposing (..)

renderMessages : List Message -> Element
renderMessages ms =
    E.flow E.up <| List.map renderOne ms

renderOne : Message -> Element
renderOne {name, body, time} =
    let message = String.join " - " [name, body, toString time]
    in Text.fromString message |> E.leftAligned

bgColor : Color -> Color
bgColor c =
    if | c == Color.blue -> Color.lightBlue
       | c == Color.red -> Color.lightRed
       | c == Color.green -> Color.lightGreen
       | c == Color.yellow -> Color.lightYellow
       | c == Color.purple -> Color.lightPurple
       | c == Color.orange -> Color.lightOrange
       | otherwise -> Color.darkGray

render : (Int, Int) -> String -> Color -> List Message -> Element -> Element
render (w,h) name color messages post =
    E.flow E.down [(renderMessages messages), post]
        |> E.container (min w 500) (min h 600) E.midBottom
        |> E.color Color.lightGray
        |> E.container w h E.middle
        |> E.color (bgColor color)

