import spot 
from collections import defaultdict


def automata_dfs(a):
    stack = []
    visited = defaultdict(bool)
    v = a.get_init_state()
    stack.append(v)
    while stack:
        curr_vertex = stack.pop()
        if not visited[curr_vertex]:
            visited[curr_vertex] = True
            for neighbors in 

ltl = "(a U b) & GFc & GFd"

ltl = "a U b"
f = spot.formula(ltl)

spot.nesting_depth(f, "U")

a = spot.translate(ltl, "deterministic", "generic", "sbacc")


# how many states

first_edge = None
for e in a.edges():
    first_edge = e
    print(first_edge)
    break

dir(first_edge)

first_edge.acc
first_edge.cond

first_edge.data

n_states = a.num_states()

dir(a)

g = a.get_graph()

dir(g)

g.disown()

dir(a)

a.edge_data()

init_state = a.get_init_state()
init_state.this

dir(init_state)

bdd_dict = a.get_dict()
dir(bdd_dict)

a.scc_filter_states()


