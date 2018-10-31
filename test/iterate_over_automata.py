import spot

ltl = "(a U b) & GFc & GFd"

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
edges = []
labels = []
for s in range(0, a.num_states()):
    print("State :{}".format(s))
    for t in a.out(s):
        ud = a.is_univ_dest(t)
        if not ud:
            for dest in a.univ_dests(t):
                edges.append((int(t.src), int(dest)))
                labels.append(str(spot.bdd_format_formula(bddict, t.cond)))
        

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
