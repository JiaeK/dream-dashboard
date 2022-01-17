let () =
  let dream_dashboard = Dream_dashboard.router ~prefix:"/" () in
  Dream.run @@ Dream.logger @@ dream_dashboard @@ Dream.not_found
