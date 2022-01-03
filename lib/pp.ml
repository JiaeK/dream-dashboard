module S = Set.Make (String)

let avoid_keyword =
  let keywords =
    S.of_list
      [
        "ALL";
        "ALTER";
        "ANY";
        "AS";
        "ASC";
        "BEGIN";
        "BY";
        "CREATE";
        "CONTINUOUS";
        "DATABASE";
        "DATABASES";
        "DEFAULT";
        "DELETE";
        "DESC";
        "DESTINATIONS";
        "DIAGNOSTICS";
        "DISTINCT";
        "DROP";
        "DURATION";
        "END";
        "EVERY";
        "EXPLAIN";
        "FIELD";
        "FOR";
        "FROM";
        "GRANT";
        "GRANTS";
        "GROUP";
        "GROUPS";
        "IN";
        "INF";
        "INSERT";
        "INTO";
        "KEY";
        "KEYS";
        "KILL";
        "LIMIT";
        "SHOW";
        "MEASUREMENT";
        "MEASUREMENTS";
        "NAME";
        "OFFSET";
        "ON";
        "ORDER";
        "PASSWORD";
        "POLICY";
        "POLICIES";
        "PRIVILEGES";
        "QUERIES";
        "QUERY";
        "READ";
        "REPLICATION";
        "RESAMPLE";
        "RETENTION";
        "REVOKE";
        "SELECT";
        "SERIES";
        "SET";
        "SHARD";
        "SHARDS";
        "SLIMIT";
        "SOFFSET";
        "STATS";
        "SUBSCRIPTION";
        "SUBSCRIPTIONS";
        "TAG";
        "TO";
        "USER";
        "USERS";
        "VALUES";
        "WHERE";
        "WITH";
        "WRITE";
      ]
  in
  fun m -> if S.mem (String.uppercase_ascii m) keywords then "o" ^ m else m

let escape =
  List.fold_right (fun e m' ->
      String.concat ("\\" ^ Char.escaped e) (String.split_on_char e m'))

let escape_measurement m = escape [ ','; ' ' ] (avoid_keyword m)

let escape_name m = escape [ ','; ' '; '=' ] (avoid_keyword m)

let pp_value (str : string Fmt.t) ppf f =
  let open Metrics in
  match value f with
  | V (String, s) -> str ppf s
  | V (Int, i) -> Fmt.pf ppf "%di" i
  | V (Int32, i32) -> Fmt.pf ppf "%ldi" i32
  | V (Int64, i64) -> Fmt.pf ppf "%Ldi" i64
  | V (Uint, u) -> Fmt.pf ppf "%ui" u
  | V (Uint32, u32) -> Fmt.pf ppf "%lui" u32
  | V (Uint64, u64) -> Fmt.pf ppf "%Lui" u64
  | _ -> pp_value ppf f

(* we need to: - avoid keywords - escape comma and space in measurement name -
   escape comma, space and equal in tag key, tag value, field key of type string
   - double-quote field value of type string - data type number is a float,
   suffix i for integers *)
let encode tags data name =
  let data_fields = Metrics.Data.fields data in
  let pp_field_str ppf s = Fmt.pf ppf "%S" s in
  let pp_field ppf f =
    Fmt.(pair ~sep:(any "=") string (pp_value pp_field_str))
      ppf
      (escape_name (Metrics.key f), f)
  in
  let pp_fields = Fmt.(list ~sep:(any ",") pp_field) in
  let pp_tag_str ppf s = Fmt.string ppf (escape_name s) in
  let pp_tag ppf f =
    Fmt.(pair ~sep:(any "=") string (pp_value pp_tag_str))
      ppf
      (escape_name (Metrics.key f), f)
  in
  let pp_tags = Fmt.(list ~sep:(any ",") pp_tag) in
  Fmt.str "%s,%a %a\n" (escape_measurement name) pp_tags tags pp_fields
    data_fields
