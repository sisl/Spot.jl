using PyCall 
using Conda

const SPOT_DEV_URL = "https://gitlab.lrde.epita.fr/spot/spot/-/jobs/21743/artifacts/download"
# const SPOT_DEV_URL = "https://gitlab.lrde.epita.fr/spot/spot/-/jobs/21303/artifacts/download"

const SPOT_VERSION = "spot-2.6.3.dev"

if !Sys.isunix()
    throw("Windows not supported")
end

# borrowed from TensorFlow.jl
if PyCall.conda
    println("Building Spot from source...")
    pyversion = PyCall.pyversion
    base = dirname(@__FILE__)
    println("Switching to directory $base")
    cd(base)
    isfile("$SPOT_VERSION.zip") ? nothing : run(`wget -O $SPOT_VERSION.zip $SPOT_DEV_URL`)
    run(`unzip $SPOT_VERSION.zip`)
    run(`rm $SPOT_VERSION.zip`)
    run(`tar -xzf $SPOT_VERSION.tar.gz`) # extract
    isdir("spot") ? mkdir("spot") : nothing
    cd(SPOT_VERSION)
    run(`./configure CXX=g++-7 PYTHON=$(Conda.PYTHONDIR)/python --prefix $(joinpath(base, "spot"))`)
    run(`make`)
    run(`make install`)
    println(readdir(joinpath(base, "spot", "lib"))
    @assert isdir(joinpath(base, "spot"))
    @assert isdir(joinpath(base, "spot", "lib", "python"*string(pyversion.major)*"."*string(pyversion.minor), "site-packages"))
    println("Python bindings located at: ", joinpath(base, "spot", "lib", "python"*string(pyversion.major)*"."*string(pyversion.minor), "site-packages"))
    println("build successful")
    println("Linking python bindings to Conda.jl")
    conda_path = joinpath(Conda.ROOTENV, "lib", "python"*string(pyversion.major)*"."*string(pyversion.minor), "site-packages")
    pythonspot = joinpath(base, "spot", "lib", "python3.6", "site-packages")
    cd(conda_path)
    run(`ln -sf $pythonspot/spot`)
    run(`ln -sf $pythonspot/_buddy.a`)
    run(`ln -sf $pythonspot/_buddy.la`)
    run(`ln -sf $pythonspot/_buddy.so`)
    run(`ln -sf $pythonspot/buddy.py`)
else
    try
        pyimport("spot")
    catch ee
        typeof(ee) <: PyCall.PyError || rethrow(ee)
        error("""
Python Spot not installed
Please either:
 - Rebuild PyCall to use Conda, by running in the julia REPL:
    - `ENV["PYTHON"]=""; Pkg.build("PyCall"); Pkg.build("Spot")`
 - Or install the python binding yourself:
 Install Spot from https://spot.lrde.epita.fr/install.html 
 Find the python bindings in path/to/spot/lib/python3.x/site-packages
""")
    end
end
