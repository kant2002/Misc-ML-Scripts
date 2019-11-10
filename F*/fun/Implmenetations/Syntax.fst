module Syntax

open FStar.All
open FStar.Ref
open FStar.Exn

// make this better typed
type expr (a : Type u#0) : Type =
  | Enum    : num:ℤ                           → expr a
  | EVar    : name:string                     -> expr a
  | EConstr : ℤ -> ℤ                           -> expr a
  | EApp    : expr a -> expr a                 -> expr a
  | ELet    : is_rec:bool → list (a * expr a) → expr a
  | ELam    : args:list a -> expr a            -> expr a

and alter 'a : Type =
  | Alt : int → list string -> expr 'a -> alter 'a

type expr_program = expr string

(* Super combinator requirements *)
type sc_defn a    = string * list a * expr a
type core_sc_defn = sc_defn string

(* A core program is a list of super combinators *)
type program a    = list (sc_defn a)
type core_program = program string

let test1 = EVar "auto"
let test2 = EApp (EApp (EVar "+") (EVar "x")) (EVar "y")

val rhs : xs : list ('a * 'b) -> list 'b
let rhs xs = List.Tot.map snd xs

val is_atomic_expr : expr 'a -> bool
let is_atomic_expr = function
  | EVar _ | Enum _ -> true
  | _               -> false


val prelude_defn : core_program
let prelude_defn =
  [ ("I", ["x"], EVar "x");
    ("K", ["x"; "y"], EVar "x");
    ("K1", ["x";"y"], EVar "y");
    ("S", ["f";"g";"x"], EApp (EApp (EVar "f") (EVar "x"))
                              (EApp (EVar "g") (EVar "x")));
    ("compose", ["f";"g";"x"], EApp (EVar "f")
                                    (EApp (EVar "g") (EVar "x")));
    ("twice", ["f"], EApp (EApp (EVar "compose") (EVar "f"))
                          (EVar "f"))
  ]