open Core
open Async
open Market_fanout

let test_subscribe_unsubscribe () =
  let mux = Multiplexer.create () in
  let sub1 = Subscriber.create ~id:"Test-1" (fun _ -> Deferred.unit) in
  let sub2 = Subscriber.create ~id:"Test-2" (fun _ -> Deferred.unit) in

  Multiplexer.subscribe mux sub1;
  Multiplexer.subscribe mux sub2;
  assert (Multiplexer.subscriber_count mux = 2);
  printf "✅ Subscribe test passed\n";

  Multiplexer.unsubscribe mux "Test-1";
  assert (Multiplexer.subscriber_count mux = 1);
  printf "✅ Unsubscribe test passed\n";
  Deferred.unit

let test_publish () =
  let mux = Multiplexer.create () in
  let received = ref 0 in

  let sub = Subscriber.create ~id:"Counter"
    (fun _ -> incr received; Deferred.unit)
  in
  Multiplexer.subscribe mux sub;

  let%bind () = Multiplexer.publish mux Market_data.Heartbeat in
  let%bind () = Multiplexer.publish mux Market_data.Heartbeat in
  let%bind () = Multiplexer.publish mux Market_data.Heartbeat in

  assert (!received = 3);
  printf "✅ Publish test passed (received %d messages)\n" !received;
  Deferred.unit

let test_fanout () =
  let mux = Multiplexer.create () in
  let count = ref 0 in

  (* Add 5 subscribers *)
  List.iter (List.range 1 6) ~f:(fun i ->
    let sub = Subscriber.create ~id:(sprintf "Sub-%d" i)
      (fun _ -> incr count; Deferred.unit)
    in
    Multiplexer.subscribe mux sub
  );

  let%bind () = Multiplexer.publish mux
    (Market_data.Trade (Market_data.create_tick
      ~symbol:"TCS" ~price:3650.0 ~volume:100))
  in

  assert (!count = 5);
  printf "✅ Fan-out test passed (delivered to %d subscribers)\n" !count;
  Deferred.unit

let () =
  don't_wait_for (
    printf "\n=== Running Tests ===\n\n";
    let%bind () = test_subscribe_unsubscribe () in
    let%bind () = test_publish () in
    let%bind () = test_fanout () in
    printf "\n=== All Tests Passed! ===\n";
    Shutdown.exit 0
  );
  never_returns (Scheduler.go ())