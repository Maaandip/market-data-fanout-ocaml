open Core
open Async

type t = {
  mutable subscribers : Subscriber.t list;
  mutex               : Monitor.t;
}

let create () = {
  subscribers = [];
  mutex       = Monitor.create ();
}

let subscribe t sub =
  t.subscribers <- sub :: t.subscribers;
  printf "Subscribed: %s (total: %d)\n"
    (Subscriber.id sub)
    (List.length t.subscribers)

let unsubscribe t id =
  t.subscribers <- List.filter t.subscribers
    ~f:(fun s -> not (String.equal (Subscriber.id s) id));
  printf "Unsubscribed: %s (total: %d)\n"
    id (List.length t.subscribers)

let publish t data =
  printf "Publishing: %s to %d subscribers\n"
    (Market_data.to_string data)
    (List.length t.subscribers);
  Deferred.List.iter t.subscribers ~how:`Parallel
    ~f:(fun sub -> Subscriber.deliver sub data)

let subscriber_count t =
  List.length t.subscribers