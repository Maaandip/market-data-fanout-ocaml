(** Market data types *)

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

val create_tick : symbol:string -> price:float -> volume:int -> tick
val to_string   : t -> string