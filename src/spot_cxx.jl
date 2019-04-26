using Cxx
using Libdl

const path_to_lib = "/mnt/c/Users/Maxime/wsl/.julia/dev/Spot/deps/spot/lib"
const path_to_header = "/mnt/c/Users/Maxime/wsl/.julia/dev/Spot/deps/spot/include"
addHeaderDir(path_to_header, kind=C_System)
Libdl.dlopen(path_to_lib * "/libspot.so", Libdl.RTLD_GLOBAL)

cxx"#include <iostream>"
cxx"#include <spot/tl/parse.hh>"
cxx"#include <spot/twaalgos/translate.hh>"
cxx"#include <spot/twaalgos/dot.hh>"
cxx"#include <spot/twaalgos/isdet.hh>"
# cxx"#include <spot/twaalgos/hoa.hh>"

f = @cxx spot::parse_formula(pointer("FGa"))

@cxx f -> is_sugar_free_ltl()

@cxx f -> is_eventual()

icxx"std::cout << $f << '\n';";

# automata conversion 

cxx"spot::translator trans;"

trans = @cxxnew spot::translator()
autom_type = @cxxnew spot::postprocessor::BA
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