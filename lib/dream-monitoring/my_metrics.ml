type cpu_times = {
  user : int;
  nice : int;
  sys : int;
  idle : int;
  irq : int;
  total : int;
}

let read_cpu () =
  match Luv.System_info.cpu_info () with
  | Error _ | Ok [] -> None
  | Ok (cpu :: _) ->
      let user = Unsigned.UInt64.to_int cpu.times.user in
      let nice = Unsigned.UInt64.to_int cpu.times.nice in
      let sys = Unsigned.UInt64.to_int cpu.times.sys in
      let idle = Unsigned.UInt64.to_int cpu.times.idle in
      let irq = Unsigned.UInt64.to_int cpu.times.irq in
      let total = user + nice + sys + irq in
      Some { user; nice; sys; idle; irq; total }

open Metrics

let proc_cpu_src ~tags =
  let doc = "Processor cpu counters" in
  let graph = Graph.v ~title:doc ~ylabel:"value" () in
  let data () =
    match read_cpu () with
    | None -> Data.v []
    | Some cpu ->
        Data.v
          [
            uint "user" ~graph cpu.user;
            uint "nice" ~graph cpu.nice;
            uint "sys" ~graph cpu.sys;
            uint "idle" ~graph cpu.idle;
            uint "irq" ~graph cpu.irq;
            uint "total" ~graph cpu.total;
          ]
  in
  Src.v ~doc ~tags ~data "proc_cpu"

let open_fds ~tags =
  let doc = "Number of open file descriptors" in
  let graph = Graph.v ~title:doc ~ylabel:"value" () in
  let dir = Printf.sprintf "/proc/%d/fd" (Unix.getpid ()) in
  let data () =
    let h = Unix.opendir dir in
    Fun.protect
      ~finally:(fun () -> Unix.closedir h)
      (fun () ->
        let rec inner count =
          try
            let name = Unix.readdir h in
            match name with
            | "." -> inner count
            | ".." -> inner count
            | _ -> inner (count + 1)
          with End_of_file -> count
        in
        let fds = inner 0 in
        Data.v [ uint "open_fds" ~graph fds ])
  in
  Src.v ~doc ~tags ~data "open_fds"
