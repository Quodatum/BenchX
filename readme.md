# benchmark.xq

A Web App packaging of the [XMark](http://www.xml-benchmark.org) benchmark for BaseX.
Version 7.8.2 of BaseX is required as the query timeout functionality of xquery:eval is used.

# Installation

1. copy the contents of the `src` folder to your `webapp` folder 
1. Start `basexhttp`
1. In browser navigate to `/benchx`

# Target file or database
The queries reference `doc("benchx-db/auction.xml")` so will run against the 
database `benchx-db`if it exists otherwise they use the file system.

# xmlgen
Binaries are supplied for Windows and x86 Linux. For other platforms e.g. ARM you 
must recompile from the supplied `unix.c`. E.g.
`gcc -o xmlgen unix.c`


# data structures
````
{
  "run": {
    "runtime": 116,
    "status": "",
    "name": "q02.xq",
    "mode": "D",
    "factor": "0.25",
    "created": "2014-05-21T21:25:28.793+01:00",
    "src:"?library id"
  }
}
````
status: "" run was ok, otherwise $err:code

# tests
## server
 XQuery unit tests in src/benchx/test
 
## client 
Uses Angular and a number of other javascript libraries.
## Contributions
Pull requests with additional result timings, 
new suites or general improvements and fixes are all welcome.