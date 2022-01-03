(** This module provides some system information *)

val ocaml_version : string
(** [ocaml_version] is the version of the OCaml compiler used to compile the
    project. *)

val version : unit -> string
(** [version ()] returns the version of the dashboard library. *)

val dream_version : unit -> string
(** [dream_version ()] returns the version of Dream that was statically linked
    when building the project. *)

val uptime : unit -> float
(** [uptime ()] returns the uptime of the system in seconds. *)

val os_type : string

val architecture : string

val cpu_usage : unit -> float
(** [cpu_usage ()] returns the CPU usage in percent. *)
