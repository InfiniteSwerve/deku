open Crypto;
open Helpers;

module Implicit = {
  open Key_hash;
  type t = Key_hash.t;

  let of_key = of_key;
  let matches_key = (key, t) => equal(of_key(key), t);

  let make = () => {
    let (key, pub_) = Ed25519.generate();
    let wallet_address = of_key(Ed25519(pub_));

    (Secret.Ed25519(key), wallet_address);
  };
  let to_key_hash = t => t;
  let of_key_hash = t => t;

  let to_string = to_string;
  let of_string = of_string;

  let to_yojson = to_yojson;
  let of_yojson = of_yojson;

  let compare = compare;
  let equal = equal;
};

module Originated = {
  open Tezos.Contract_hash;
  type nonrec t = t;

  let to_contract_hash = t => t;
  let of_contract_hash = t => t;

  let to_string = to_string;
  let of_string = of_string;

  let to_yojson = to_yojson;
  let of_yojson = of_yojson;

  let compare = compare;
};

[@deriving (yojson, ord)]
type t =
  | Implicit(Implicit.t)
  | Originated(Originated.t);

let of_implicit = implicit => Implicit(implicit);
let to_implicit = t =>
  switch (t) {
  | Implicit(implicit) => Some(implicit)
  | _ => None
  };

let to_string =
  fun
  | Implicit(implicit) => Implicit.to_string(implicit)
  | Originated(contract_hash) =>
    Tezos.Contract_hash.to_string(contract_hash);

let of_string = {
  let implicit = string => {
    let.some key_hash = Implicit.of_string(string);
    Some(Implicit(key_hash));
  };
  let contract = string => {
    let.some contract_hash = Tezos.Contract_hash.of_string(string);
    Some(Originated(contract_hash));
  };
  Encoding_helpers.parse_string_variant([implicit, contract]);
};
