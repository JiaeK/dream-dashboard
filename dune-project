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
  dream
  dune-build-info
  luv
  user-agent-parser
  (alcotest :with-test)
  (odoc :with-doc)))
