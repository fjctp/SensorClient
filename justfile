set dotenv-load

# Initialize the project for the first time by installing dependencies
init: (repl "-e 'using Pkg; Pkg.instantiate()'")

# Run the main script
run: (repl "main.jl")

# Run the main script
test: (repl "test/runtests.jl")

# Run a Julia interactive shell
repl command="":
  # Define LD_LIBRARY_PATH due to nix.
  LD_LIBRARY_PATH=/run/opengl-driver/lib/ julia -t4 --project=. {{command}}

