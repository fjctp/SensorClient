
# See 
# - https://discourse.julialang.org/t/best-way-to-install-and-use-julia-on-nix-nixos/109948/12
# - https://gist.github.com/konfou/d12c0a26fc0d3b432dc9d23c86701fcb
# - https://github.com/jheinen/GR.jl/issues/454
with import <nixpkgs> {};
  pkgs.mkShell {
    name = "sensor-client";
    nativeBuildInputs = with pkgs; [
      julia
      patchelf
    ];
    shellHook = ''
    export JULIA_OPENSPECFUN_LIB=`find ~/.julia/artifacts -iname libopenspecfun.so`
     sudo ${patchelf}/bin/patchelf --replace-needed libgfortran.so.5 ${julia}/lib/julia/libgfortran.so.5 $JULIA_OPENSPECFUN_LIB
     sudo ${patchelf}/bin/patchelf --replace-needed libquadmath.so.0 ${julia}/lib/julia/libquadmath.so.0 $JULIA_OPENSPECFUN_LIB

     #ldd $JULIA_OPENSPECFUN_LIB
    '';
}
