let () = Printexc.record_backtrace true

open Import

let ocaml_version = Sys.ocaml_version

let version () =
  let open Build_info.V1 in
  match version () with
  | None -> "dev"
  | Some version -> Version.to_string version

let dream_version () =
  let open Build_info.V1 in
  match Statically_linked_libraries.find ~name:"dream" with
  | None -> "unknown"
  | Some library -> (
      match Statically_linked_library.version library with
      | None -> "dev"
      | Some version -> Version.to_string version)

let uptime =
  let init = Unix.gettimeofday () in
  fun () -> Unix.gettimeofday () -. init

type platform = Darwin | Freebsd | Linux | Openbsd | Sunos | Win32 | Android

type arch =
  | Arm
  | Arm64
  | Ia32
  | Mips
  | Mipsel
  | Ppc
  | Ppc64
  | S390
  | S390x
  | X32
  | X64

let platform_of_string = function
  | "darwin" -> Darwin
  | "freebsd" -> Freebsd
  | "linux" -> Linux
  | "openbsd" -> Openbsd
  | "sunos" -> Sunos
  | "win32" -> Win32
  | "android" -> Android
  | platform ->
      print_endline (Printf.sprintf "Unsupported architecture %s" platform);
      assert false

let arch_of_string = function
  | "arm" -> Arm
  | "arm64" -> Arm64
  | "ia32" -> Ia32
  | "mips" -> Mips
  | "mipsel" -> Mipsel
  | "ppc" -> Ppc
  | "ppc64" -> Ppc64
  | "s390" -> S390
  | "s390x" -> S390x
  | "x86_32" | "x32" -> X32
  | "x86_64" | "x64" -> X64
  | arch ->
      print_endline (Printf.sprintf "Unsupported architecture %s" arch);
      assert false

let arch_string =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  uname.Luv.System_info.Uname.machine

let arch = arch_of_string arch_string

let platform_string =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  String.lowercase_ascii uname.Luv.System_info.Uname.sysname

let platform = platform_of_string platform_string

let sysname () =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  uname.Luv.System_info.Uname.sysname

let os_release () =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  uname.Luv.System_info.Uname.release

let os_version () =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  uname.Luv.System_info.Uname.version

let os_machine () =
  let open Result.Syntax in
  let@ () = handle_sys_error in
  let+ uname = Luv.System_info.uname () in
  uname.Luv.System_info.Uname.machine

let get_field name data =
  let fields = Metrics.Data.fields data in
  List.find (fun field -> Metrics.key field = name) fields

module Metrics_field = struct
  let float f =
    match Metrics.value f with
    | V (Float, x) -> (x : float)
    | _ -> failwith "wrong type for metrics field"

  let uint f =
    match Metrics.value f with
    | V (Uint, x) -> (x : int)
    | _ -> failwith "wrong type for metrics field"
end

let rusage_src = Metrics_rusage.rusage_src ~tags:[]
let kinfo_mem_src = Metrics_rusage.kinfo_mem_src ~tags:[]
let proc_cpu_src = My_metrics.proc_cpu_src ~tags:[]
let proc_fds_src = My_metrics.open_fds ~tags:[]
let cpu_usage () = 0.42
(* Patrik does not know how to return the cpu usage found below *)

let () =
  let interval = 1.0 in
  Metrics.enable_all ();
  Metrics_lwt.init_periodic (fun () -> Lwt_unix.sleep interval);
  Metrics_lwt.periodically rusage_src;
  Metrics_lwt.periodically kinfo_mem_src;
  Metrics_lwt.periodically proc_cpu_src;
  Metrics_lwt.periodically proc_fds_src;

  let get_metrics, reporter = Metrics.cache_reporter () in
  Metrics.set_reporter reporter;
  let past_rusage = ref None in
  let past_proc_cpu = ref None in
  let report () =
    try
      let _tags, rusage_data =
        Metrics.SM.find (Src rusage_src) (get_metrics ())
      in
      let _tags, proc_cpu_data =
        Metrics.SM.find (Src proc_cpu_src) (get_metrics ())
      in
      let _tags, proc_fds_data =
        Metrics.SM.find (Src proc_fds_src) (get_metrics ())
      in
      match (!past_rusage, !past_proc_cpu) with
      | None, _ | _, None ->
          past_rusage := Some rusage_data;
          past_proc_cpu := Some proc_cpu_data
      | Some past_rusage_data, Some past_proc_cpu_data ->
          let utime_before =
            Metrics_field.float (get_field "utime" past_rusage_data)
          in
          let utime_after =
            Metrics_field.float (get_field "utime" rusage_data)
          in

          let total_before =
            Int.to_float
              (Metrics_field.uint (get_field "total" past_proc_cpu_data))
          in
          let total_after =
            Int.to_float (Metrics_field.uint (get_field "total" proc_cpu_data))
          in

          let cpu_usage =
            100.
            *. ((utime_after -. utime_before) /. (total_after -. total_before))
          in

          past_rusage := Some rusage_data;
          past_proc_cpu := Some proc_cpu_data;
          print_endline
            (Printf.sprintf "open_fds: %d"
               (Metrics_field.uint (get_field "open_fds" proc_fds_data)));
          print_endline
            (Printf.sprintf "CPU Usage: %f\n total: %d" cpu_usage
               (Metrics_field.uint (get_field "total" proc_cpu_data)))
    with Not_found -> ()
  in
  let rec aux () =
    let open Lwt.Syntax in
    report ();
    let* () = Lwt_unix.sleep 5. in
    aux ()
  in
  Lwt.async aux
