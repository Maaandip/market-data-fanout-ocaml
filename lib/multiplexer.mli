(** Async market data fan-out multiplexer *)

open Async

type t

val create      : unit -> t
val subscribe   : t -> Subscriber.t -> unit
val unsubscribe : t -> string -> unit
val publish     : t -> Market_data.t -> unit Deferred.t
val subscriber_count : t -> int