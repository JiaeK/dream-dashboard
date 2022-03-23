# Dream Dashboard 

Analytics and Monitoring dashboard for Dream

*Note: Currently this repository continues to be a work in progress after being integrated into the repository of ocaml.org. It will upstream soon on ocaml.org.*

## Set up your development environment

You need opam. You can install it by following [opam's documentation](https://opam.ocaml.org/doc/Install.html).

With opam installed, you can install the dependencies in a new local switch with:

```bash
make switch
```

Or globally, with:

```bash
make deps
```

Then, build the project with:

```bash
make build
```

### Running the server

After building the project, you can run the server with:

```bash
make start
```

To start the server in watch mode, you can run:

```bash
make watch
```

This will restart the server on filesystem changes and reload the pages automatically.

### Running tests

You can run the unit test suite with:

```bash
make test
```

### Building documentation

Documentation for the libraries in the project can be generated with:

```bash
make doc
```

### Repository structure

The following snippet describes Dream Dashboard's repository structure.

```text
.
├── example/
|   Source for dream-dashboard's example. This links to the library defined in `lib/`.
│
├── lib/
|   Source for Dream Dashboard's library. Contains Dream Dashboard's core functionalities.
│
├── test/
|   Unit tests and integration tests for Dream Dashboard.
│
├── dune-project
|   Dune file used to mark the root of the project and define project-wide parameters.
|   For the documentation of the syntax, see https://dune.readthedocs.io/en/stable/dune-files.html#dune-project.
│
├── LICENSE
│
├── Makefile
|   `Makefile` containing common development commands.
│
├── README.md
│
└── dream-dashboard.opam
    opam package definition.
    To know more about creating and publishing opam packages, see https://opam.ocaml.org/doc/Packaging.html.
```
