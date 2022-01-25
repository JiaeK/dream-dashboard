module Handler = struct
  let index ~prefix _req =
    Dream.html
      (Index_template.render ~prefix ~ocaml_version:Info.ocaml_version
         ~dream_version:(Info.dream_version ())
         ~dashboard_version:(Info.version ()) ~platform:Info.platform_string
         ~architecture:Info.arch_string ~uptime:(Info.uptime ()) ())
end

module Router = struct
  let loader _root path _request =
    match Asset.read path with
    | None -> Dream.empty `Not_Found
    | Some asset -> Dream.respond asset

  let routes prefix middlewares =
    Dream.scope prefix middlewares
      [
        Dream.get "/" (Handler.index ~prefix);
        Dream.get "/assets/**" (Dream.static ~loader "");
      ]

  let router prefix middlewares = Dream.router [ routes prefix middlewares ]
end

let router ?(prefix = "/dashboard") ?(middlewares = []) () =
  Router.router prefix middlewares

module Private = struct
  module Handler = Handler
end
