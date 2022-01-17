let () =
  Dream.run @@ Dream.logger
  @@ Dream_dashboard.router ~prefix:"/dashboard/" ()
  @@ Dream_dashboard.analytics ()
  @@ Dream.router
       [
         Dream.get "/" (fun _req ->
             Dream.html {|Hello World!<br><a href="/test">Go to test</a>|});
         Dream.get "/test" (fun _req ->
             Dream.html {|Hello World!<br><a href="/test">Go home</a>|});
       ]
  @@ Dream.not_found
