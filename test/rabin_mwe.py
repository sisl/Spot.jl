import sys
sys.path.append("/mnt/c/Users/Maxime/wsl/.julia/dev/Spot/deps/spot/lib/python3.6/site-packages/")

import spot 

# This works
dpa = spot.translate('GFa -> GFb', 'parity min odd', 'det')
dra = spot.to_generalized_rabin(dpa)
acc = dra.acc()
print(acc)
(b, v) = acc.is_rabin_like()
print("dra is rabin: ", b)
print(" Sets: ", v)


# This does not seem to work 
aut2 = spot.translate('(a U b) & GFc & GFd', 'det', 'sbacc', 'ba')
acc = aut2.acc()
print(acc)  # Inf(0)&Inf(1)
(b, v) = acc.is_rabin_like()
print("aut2 is rabin: ", b)
print(" Sets: ", v)
dra2 = spot.to_generalized_rabin(aut2)
acc = dra2.acc()
print(acc) # Fin(0) & (Inf(1) & Inf(2))
(b, v) = acc.is_rabin_like()
print("dra2 is rabin: ", b) #XXX Shouldn't this be true
print(" Sets: ", v) #XXX Shouldn't this be fin={0}, inf=({1},{2})

(b, v) = acc.is_generalized_rabin()
print("dra2 is generalized rabin: ", b)
print(" Sets: ", v)