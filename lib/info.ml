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

let uptime () = Sys.time ()

let os_type = Sys.os_type

let architecture = failwith "TODO"

let () =
  let open Lwt.Syntax in
  let interval = 5.0 in
  Metrics.enable_all ();
  Metrics_lwt.init_periodic (fun () -> Lwt_unix.sleep interval);
  Metrics_lwt.periodically (Metrics_rusage.rusage_src ~tags:[]);
  Metrics_lwt.periodically (Metrics_rusage.kinfo_mem_src ~tags:[]);
  let get_cache, reporter = Metrics.cache_reporter () in
  Metrics.set_reporter reporter;
  let rec report () =
    let send () =
      let datas =
        Metrics.SM.fold
          (fun src (tags, data) acc ->
            let name = Metrics.Src.name src in
            Pp.encode tags data name :: acc)
          (get_cache ()) []
      in
      let datas = String.concat "" datas in
      print_endline datas;
      Lwt.return ()
    and sleep () = Lwt_unix.sleep interval in
    let* () = Lwt.join [ send (); sleep () ] in
    report ()
  in
  Lwt.async report

let cpu_usage () = failwith "TODO"

(* let timer pid vmmapi interval = let rusage, kinfo_mem = sysctl_kinfo_proc pid
   in Logs.app (fun m -> m "sysctl rusage: %a" Stats.pp_rusage_mem rusage) ;
   Logs.app (fun m -> m "kinfo mem: %a" Stats.pp_kinfo_mem kinfo_mem) ; let
   delta, pct = if !old_rt = 0L then let delta = kinfo_mem.Stats.runtime in let
   now = Unix.gettimeofday () in let start = Int64.to_float (fst
   kinfo_mem.start) +. ((float_of_int (snd kinfo_mem.start)) /. 1_000_000_000.)
   in delta, Int64.to_float delta /. ((now -. start) *. 1_000_000.) else let
   delta = Int64.sub kinfo_mem.Stats.runtime !old_rt in delta, Int64.to_float
   delta /. (interval *. 1_000_000.) in Logs.app (fun m -> m "delta %Lu pct %f"
   delta pct) ; old_rt := kinfo_mem.Stats.runtime; match vmmapi with | None ->
   () | Some vmctx -> match wrap vmmapi_stats vmctx with | None -> Logs.app (fun
   m -> m "no vmctx stats") | Some st -> let all = List.combine !descr st in
   Logs.app (fun m -> m "bhyve stats %a" Stats.pp_vmm_mem all) *)

(* Add functions for host system info, like the OS, the architecture, etc. *)
