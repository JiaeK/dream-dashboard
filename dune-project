(lang dune 2.7)

(name dream-dashboard)

(license ISC)

(authors "Jiae Kam")

(maintainers "Jiae Kam")

(generate_opam_files true)

(package
 (name dream-dashboard)
 (synopsis "Analytics and Monitoring dashboard for Dream")
 (description "Analytics and Monitoring dashboard for Dream")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  crunch
  (dream
   (>= 1.0.0~alpha3))
  dune-build-info
  luv
  metrics-lwt
  user-agent-parser
  mmdb
  digestif
  (alcotest :with-test)
  (odoc :with-doc)))
