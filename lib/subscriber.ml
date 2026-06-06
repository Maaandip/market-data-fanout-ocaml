open Core
open Async

type t = {
  id      : string;
  handler : Market_data.t -> unit Deferred.t;
}

let create ~id handler = { id; handler }

let id t = t.id

let deliver t data =
  t.handler data

let to_string t =
  sprintf "Subscriber(%s)" t.id