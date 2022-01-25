val router :
  ?prefix:string ->
  ?middlewares:Dream.middleware list ->
  unit ->
  Dream.middleware
(** A Dream middleware that will serve the dashboard under the [prefix]
    endpoint. If prefix is not specified, it will be [/dashboard] by default. *)

(** Private modules for tests only. *)
module Private : sig
  module Handler : sig
    val index : prefix:string -> Dream.handler
  end
end
