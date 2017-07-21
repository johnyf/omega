------------------------------- MODULE OpenSystems -----------------------------
(* Operators for creating open systems. *)

(* Variable b starts in BOOLEAN and changes at most once to FALSE. *)
MayUnstep(b) == /\ b \in BOOLEAN
                /\ [][b' = FALSE]_b

(* The TLA+ operator -+-> expressed within the logic [1, p.337].
[1] Leslie Lamport, "Specifying systems", Addison-Wesley, 2002
*)
WhilePlus(A(_, _), G(_, _), x, y) ==
    \AA b:  \/ ~ /\ MayUnstep(b)
                 /\ \EE u, v:  /\ A(u, v)
                               /\ [] (b => (<< u, v >> = << x, y >>))
            \/ \EE u, v:
                /\ G(u, v)
                /\ << u, v >> = << x, y >>
                /\ [][ b => (<< u', v' >> = << x', y' >>) ]_<< b, u, v, x, y >>

(* A variant of the WhilePlus operator. *)
WhilePlusHalf(A(_, _), G(_, _), x, y) ==
    \AA b:
        LET
            SamePrefix(u, v) == [] (b => (<< u, v >> = << x, y >>))
        IN
            \/ ~ /\ MayUnstep(b)
                 /\ \EE u, v:  /\ A(u, v)
                               /\ SamePrefix(u, v)
            \/ \EE u, v:
                /\ G(u, v) /\ (v = y)
                /\ SamePrefix(u, v)
                /\ [][ b => (v' = y') ]_<< b, v, y >>

(* An operator that forms an open system from the closed system that the
temporal property P(x, y) describes.
*)
Unzip(P(_, _), x, y) ==
    LET A(u, v) == WhilePlusHalf(P, P, v, u)  (* swap to y, x *)
    IN WhilePlusHalf(A, P, x, y)

================================================================================
(* Copyright 2016-2017 by California Institute of Technology. *)
(* All rights reserved. Licensed under BSD-3. *)