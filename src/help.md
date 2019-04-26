```julia
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

f = @cxx spot::parse_formula(pointer("!F(red & X(yellow))"))

trans = @cxxnew spot::translator()

@cxx trans -> set_type(spot::postprocessor::BA) # XXX throw ERROR: UndefVarError: spot not defined
@cxx trans -> set_pref(spot::postprocessor::Deterministic)  # XXX throw ERROR: UndefVarError: spot not defined




aut = @cxx trans -> run(f)
```


```cpp
#include <iostream>
#include <spot/tl/parse.hh>
#include <spot/twaalgos/translate.hh>
#include <spot/twaalgos/dot.hh>

int main()
{
  spot::parsed_formula pf = spot::parse_infix_psl("!F(red & X(yellow))");
  if (pf.format_errors(std::cerr))
    return 1;
  spot::translator trans;
  trans.set_type(spot::postprocessor::Monitor);
  trans.set_pref(spot::postprocessor::Deterministic);
  spot::twa_graph_ptr aut = trans.run(pf.f);
  print_dot(std::cout, aut) << '\n';
  return 0;
}
```

Platform: WSL for linux
Julia: 1.1, Cxx master