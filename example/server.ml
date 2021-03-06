let () =
  Dream_dashboard.init ();
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream_dashboard.route ~prefix:"/dashboard" ();
         Dream.scope "/"
           [ Dream_dashboard.analytics () ]
           [
             Dream.get "/" (fun _req ->
                 Dream.html
                   {|
             <a href="/test">Go to test</a>
             <a href="/dashboard/">Go to dashboard</a>
             |});
             Dream.get "/test" (fun _req ->
                 Dream.html {|Hello World!<br><a href="/test">Go home</a>|});
           ];
       ]
