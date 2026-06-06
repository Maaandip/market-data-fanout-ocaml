open Core
open Async
open Market_fanout

let () =
  don't_wait_for (
    let mux = Multiplexer.create () in

    let sub1 = Subscriber.create ~id:"TradingBot-1"
      (fun data ->
        printf "TradingBot-1 received: %s\n" (Market_data.to_string data);
        Deferred.unit)
    in

    let sub2 = Subscriber.create ~id:"RiskEngine-2"
      (fun data ->
        printf "RiskEngine-2 received: %s\n" (Market_data.to_string data);
        Deferred.unit)
    in

    let sub3 = Subscriber.create ~id:"Logger-3"
      (fun data ->
        printf "Logger-3 received: %s\n" (Market_data.to_string data);
        Deferred.unit)
    in

    Multiplexer.subscribe mux sub1;
    Multiplexer.subscribe mux sub2;
    Multiplexer.subscribe mux sub3;

    printf "\n=== Market Data Fan-out Multiplexer ===\n\n";

    let%bind () = Multiplexer.publish mux
      (Market_data.Trade (Market_data.create_tick
        ~symbol:"TCS" ~price:3650.50 ~volume:1000))
    in
    let%bind () = Multiplexer.publish mux
      (Market_data.Quote { bid=1510.25; ask=1511.00; symbol="INFY" })
    in
    let%bind () = Multiplexer.publish mux
      Market_data.Heartbeat
    in

    printf "\n--- Unsubscribing RiskEngine-2 ---\n\n";
    Multiplexer.unsubscribe mux "RiskEngine-2";

    let%bind () = Multiplexer.publish mux
      (Market_data.Trade (Market_data.create_tick
        ~symbol:"RELIANCE" ~price:2910.75 ~volume:500))
    in

    printf "\nTotal subscribers: %d\n"
      (Multiplexer.subscriber_count mux);

    Shutdown.exit 0
  );
  never_returns (Scheduler.go ())