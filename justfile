
# Initialize the project for the first time by installing dependencies
init: (repl "-e 'using Pkg; Pkg.instantiate()'")

# Start code editor
edit:
  code .

# Run the main script
run: (repl "main.jl")

# Run the main script
test: (repl "test/runtests.jl")

# Run a Julia interactive shell
repl command="":
  LD_LIBRARY_PATH=/run/opengl-driver/lib/ julia -t4 --project=. {{command}}

