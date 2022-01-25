(lang dune 2.7)

(name dream-dashboard)

(license ISC)

(authors "Jiae Kam")

(maintainers "Jiae Kam")

(generate_opam_files true)

(package
 (name dream-monitoring)
 (synopsis "Monitoring dashboard for Dream")
 (description "Monitoring dashboard for Dream")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  crunch
  dream
  dune-build-info
  luv
  (alcotest :with-test)
  (odoc :with-doc)))

(package
 (name dream-analytics)
 (synopsis "Analytics dashboard for Dream")
 (description "Analytics dashboard for Dream")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  crunch
  dream
  user-agent-parser
  (alcotest :with-test)
  (odoc :with-doc)))
