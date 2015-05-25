# BenchX

A Web App packaging of the [XMark](http://www.xml-benchmark.org) benchmark for BaseX.
Version 8.2 or greater of BaseX is required. And:
````
  # Local Options
  MIXUPDATES = true
````
# Installation

1. copy the contents of the `src` folder to your `webapp` folder
Ensure the xmlgen executable is executable. 
On windows (`bin\win32.exe` )this is not problem
On UNIX 386 (`bin/xmlgen`) 
On other platforms you will need to compile see xmlgen section 

1. Start `basexhttp`
1. In browser navigate to `/benchx`

# Target file or database
The queries reference `collection("benchx-db")` so will run against the 
database `benchx-db`if it exists otherwise they use the folder "benchx-db" 
on file system.
The static uri of queries is set to the benchx folder.
# xmlgen
Binaries are supplied for Windows and x86 Linux. For other platforms e.g. ARM you 
must recompile from the supplied `unix.c`. E.g.
`gcc -o xmlgen unix.c`

#databases
benchx - state,library
benchx-db - holds xmlgen generated data for using in runs

#startup
checks for the `benchx` database. Creates if needed from `data` folder.
If state.xml has no `/root/server/id` value. One is generated and the hostname is updated.
 
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