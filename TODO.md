- Overview
    - Version of OCaml
    - Version of Dream (the web framework)
    - Version of the dashboard
    - Uptime
    - host system information (OS, architecture, etc.). Something similar to the output of `uname -a`

- Analytics
  - Build an histogram of the requests
  - Number of visitors (need IP if we want unique visitors)
  - Top sources (different header)
  - Top pages
  - Devices
  - Browser
  - Operating system
  - Can take https://github.com/tmattio/dream-analytics/ as a basis.

- Monitoring
  - Memory usage
  - CPU usage
  - Opened file descriptors
  - Total I/O (input and output measured in Gb)

- Logs
  - Report logs
