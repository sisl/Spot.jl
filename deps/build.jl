using PyCall 
using Conda 

const SPOT_DEV_URL = "https://gitlab.lrde.epita.fr/spot/spot/-/jobs/21303/artifacts/download"
const SPOT_VERSION = "spot-2.6.3.dev"

if !Sys.isunix()
    throw("Windows not supported")
end

# borrowed from TensorFlow.jl
if PyCall.conda
    pyversion = PyCall.pyversion
    run(`wget -O $SPOT_VERSION.zip $SPOT_DEV_URL`)
    run(`unzip $SPOT_VERSION.zip`)
    run(`rm $SPOT_VERSION.zip`)
    run(`tar -xzf $SPOT_VERSION.tar.gz`) # extract
    mkdir("spot")
    cd(SPOT_VERSION)
    run(`./configure --prefix $(joinpath(pwd(), "spot"))`)
    run(`make`)
    run(`make install`)
    cd("../")
    conda_path = joinpath(Conda.ROOTENV, "lib", "python"*string(pyversion.major)*"."*string(pyversion.minor), "site-packages")
    run(`ln -s /spot/lib/python3.6/site-packages $conda_path`)
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
