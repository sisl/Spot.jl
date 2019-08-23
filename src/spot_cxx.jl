# Just for prototyping!
using Cxx
using Libdl

const path_to_lib = joinpath(@__DIR__, "deps", "usr", "lib", "libspot.so")
const path_to_header = joinpath(@__DIR__, "deps", "usr", "include")
addHeaderDir(path_to_header, kind=C_System)
Libdl.dlopen(path_to_lib, Libdl.RTLD_GLOBAL)

struct SpotFormula
    f::Cxx.CxxCore.CppValue
end

cxx"#include <iostream>"
cxx"#include <vector>"
cxx"#include <spot/tl/formula.hh>"
cxx"#include <spot/tl/parse.hh>"
cxx"#include <spot/tl/print.hh>"
cxx"#include <spot/tl/apcollect.hh>"
cxx"#include <spot/twaalgos/translate.hh>"
cxx"#include <spot/twaalgos/dot.hh>"
cxx"#include <spot/twaalgos/isdet.hh>"
cxx"#include <spot/twaalgos/split.hh>"

f = @cxx spot::parse_formula(pointer("FGa"))
f = SpotFormula(f)

@cxx f.f -> is_eventual()
is_ltl_formula(f::SpotFormula) = @cxx f.f -> is_ltl_formula()


icxx"$f.is(spot::op::G);"

sap = @cxx spot::atomic_prop_collect(f)

vap = icxx"""
    std::vector<spot::formula> v($sap->begin(), $sap->end());
    v;
"""

function atomic_prop_collect(f)
    icxx"std::vector<spot::formula> v($sap -> begin(), $sap -> end());"
end


sf = icxx"str_psl($f);";

String(@cxx spot::str_psl(f))

icxx"std::cout << $f << '\n';";


# cxx"#include <spot/twaalgos/hoa.hh>"


@cxx f -> is_sugar_free_ltl()

@cxx f -> is_eventual()

icxx"std::cout << $f << '\n';";

# automata conversion 


f = @cxx spot::parse_formula(pointer("(a U b) & GFc & GFd"))

# cxx"spot::translator trans;"

trans = @cxx spot::translator()
# autom_type = @cxxnew spot::postprocessor::BA
autom_type = @cxx spot::postprocessor::BA
@cxx trans -> set_type(autom_type)
autom_pref = @cxx spot::postprocessor::Deterministic
@cxx trans -> set_pref(autom_pref)
aut = @cxx trans -> run(f)

@cxx spot::is_deterministic(aut)

open("digraph.dot", "w") do io
  redirect_stdout(io) do 
    icxx"print_dot(std::cout, $aut);"
  end
end
run(`dot -Tpng digraph.dot -o graph.png`)

aut = @cxx spot::split_edges(aut)

## breaking 
open("graph.svg") do f
   display("image/svg+xml", read(f, String))
end

############################# DRAFT ###############################

@cxx print_dot(cout, aut)

cxx"""
  std::string graph(const spot::const_twa_ptr & aut){
    std::stringstream buffer;
    print_dot(buffer, aut);
    return buffer.str();
  }
"""

s = @cxx graph(aut);



foo = """
<svg  xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" height="100" width="200" style="fill: blue"/>
</svg>
"""

display("image/svg+xml", foo)

dg = """
  digraph "" {
  rankdir=LR
  label="\n[Büchi]"
  labelloc="t"
  node [shape="circle"]
  I [label="", style=invis, width=0]
  I -> 0
  0 [label="0"]
  0 -> 0 [label="1"]
  0 -> 1 [label="a"]
  1 [label="1", peripheries=2]
  1 -> 1 [label="a"]
}
(class std::basic_ostream<char> &) {
}
"""

run(`dot -Tsvg digraph "" {
  rankdir=LR
  label="\n[Büchi]"
  labelloc="t"
  node [shape="circle"]
  I [label="", style=invis, width=0]
  I -> 0
  0 [label="0"]
  0 -> 0 [label="1"]
  0 -> 1 [label="a"]
  1 [label="1", peripheries=2]
  1 -> 1 [label="a"]
}
(class std::basic_ostream<char> &) {
} `)


function sprint_digraph(io::IO, aut)
    (rd, wd) = redirect_stdout(io) do
      icxx"std::cout << $aut << '\n';"
    end

end

digraph = sprint(sprint_digraph, aut)


# f2 = @cxx spot::random_ltl()

io = IOBuffer()
@cxx print_latex_psl(io, f)

function display_formula(f)

cxx"""
   std::cout << $f << '\n'"

cxxt"std::cout"