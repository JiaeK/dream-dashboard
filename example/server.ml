let () =
  Dream_monitoring.init_metrics ();
  Dream.run @@ Dream.logger
  @@ Dream_monitoring.router ~prefix:"/dashboard" ()
  @@ Dream_analytics.router ~prefix:"/analytics" ()
  @@ Dream.router
       [
         Dream.get "/" (fun _req ->
             Dream.html
               {|
             <a href="/test">Go to test</a>
             <a href="/dashboard/">Go to dashboard</a>
             <a href="/analytics/">Go to analytics</a>
             |});
         Dream.get "/test" (fun _req ->
             Dream.html {|Hello World!<br><a href="/test">Go home</a>|});
       ]
  @@ Dream.not_found
