(** Subscriber interface *)

open Async

type t

val create    : id:string -> (Market_data.t -> unit Deferred.t) -> t
val id        : t -> string
val deliver   : t -> Market_data.t -> unit Deferred.t
val to_string : t -> string