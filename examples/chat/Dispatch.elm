module Dispatch where

type alias Dispatcher a =
    { signal : Signal a
    , dispatch : a -> Signal.Message
    }

dispatcher : a -> Dispatcher a
dispatcher init =
    let {signal, address} = Signal.mailbox init
        dispatch = Signal.message address
    in Dispatcher signal dispatch
