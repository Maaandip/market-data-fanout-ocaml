open Core

type tick = {
  symbol    : string;
  price     : float;
  volume    : int;
  timestamp : float;
}

type t =
  | Trade of tick
  | Quote of { bid: float; ask: float; symbol: string }
  | Heartbeat

let create_tick ~symbol ~price ~volume = {
  symbol;
  price;
  volume;
  timestamp = Core_unix.gettimeofday ();
}

let to_string = function
  | Trade t ->
      sprintf "[TRADE] %s @ %.2f vol:%d time:%.3f"
        t.symbol t.price t.volume t.timestamp
  | Quote { bid; ask; symbol } ->
      sprintf "[QUOTE] %s bid:%.2f ask:%.2f" symbol bid ask
  | Heartbeat ->
      "[HEARTBEAT]"