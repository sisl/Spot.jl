import spot
import pdb
ltl = "(a U b) & GFc & GFd"


safety = spot.formula("!a U b")
safety_aut = spot.translate(safety, "deterministic", "BA", "sbacc")
ra = spot.to_generalized_rabin(safety_aut)
ra = spot.split_edges(ra)

def get_edges_labels(a):
    bddict = a.get_dict()
    edges = []
    labels = []
    for s in range(0, a.num_states()):
        print("State :{}".format(s))
        for t in a.out(s):
            ud = a.is_univ_dest(t)
            if not ud:
                for dest in a.univ_dests(t):
                    print("adding edge {}".format((int(t.src), int(dest))))
                    print("with label {}".format(spot.bdd_to_formula(t.cond, bddict)))
                    edges.append((int(t.src), int(dest)))
                    labels.append(spot.bdd_to_formula(t.cond, bddict))


edges, labels = get_edges_labels(ra)

for e in ra.edges():
    print("edge {}".format((int(e.src), int(e.dst))))

edge_list = [e for e in ra.edges()]

## Acceptance sets
aut = spot.translate('G F a', 'parity min odd', 'det', 'sbacc')
dra = spot.to_generalized_rabin(aut)
acc = dra.acc()
print(acc)
aut.num_states()
(b, v) = acc.is_rabin_like()
print(dra.to_str())

accset = v[0].inf
for s in range(0, dra.num_states()):
    if dra.state_acc_sets(s) == accset:
        print(s)


print(dra.state_acc_sets(1).sets())
print(accset)
print(v[0].fin)

dra.state_acc_sets(1) == v[0].inf

dir(dra)
type(accset)

type(dra.state_acc_sets(0))

v[0].fin

print(b, v)



e = edge_list[0]
dir(e)

e.src
e.dst
e.cond
spot.bdd_to_formula(e.cond, ra.get_dict())

f = spot.formula(ltl)

dir(f)

a = spot.translate(ltl, "deterministic", "generic", "sbacc")

bddict = a.get_dict()
init = a.get_init_state_number()
print("Number of states: ", a.num_states())
print("Initial state: ", init)

# get initial states
initial_states = []
for i in a.univ_dests(init):
    initial_states.append(i)

# get edges and labels formulas


        

f = labels[2]
f[1]
dir(f[1])
f

f[1].this

f[2].is_literal()

f[2][0]

f[2]._is(spot.op_Not)

f[1].ap_name()

a = f[2].get_child_of(0)
a


# get APs
aps = [str(ap) for ap in a.ap()] 

f = type(a.ap()[0])

f.to_str
dir(f)



# get acceptance conditions
acc = a.get_acceptance() # type acc_code
a.acc() # type acc_cond

dir(acc)

a.state_acc_sets(1)

a.state_is_accepting()

dir(acc)

print(a.to_str())


dir(a.ap_vars())

for ap in a.ap_vars():
    print(ap)

dir(ap)


outs = [t for t in a.out(1)]

spot.bdd_format_formula(bddict, t.cond)

t = outs[0]
t.cond

dir(bddict)

dir(t)


ud = a.is_univ_dest(outs[0])


ui = a.is_univ_dest(init)

dir(a)

ns = a.state_number

a1 = spot.translate('FGa & GFb',"deterministic", "generic", "sbacc")

acc
dir(acc)
acc.fin()

acc.fin()

acc.num_sets()

acc.acc_op_Fin

acc.acc_op_Inf

acc.all_sets()

acc.inf(0)

bc = acc.get_acceptance()

dir(bc)
dir(acc)
