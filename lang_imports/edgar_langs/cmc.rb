@edgar_langs ||= []
@edgar_langs += 
[
  {
    name: "Julia (v1.10.2)",
    is_archived: false,
    source_file: "Main.jl",
    run_cmd: "JULIA_DEPOT_PATH=/usr/local/lib/.julia /usr/local/julia-1.10.2/bin/julia Main.jl",
  }
]
