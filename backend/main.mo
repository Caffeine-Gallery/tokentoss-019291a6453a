import Hash "mo:base/Hash";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor ICRC1Token {
    // Token metadata
    private let name : Text = "My ICRC-1 Token";
    private let symbol : Text = "MIT";
    private let decimals : Nat8 = 8;
    private let fee : Nat = 1_000;

    // Balances
    private var balances = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);

    // Total supply
    private var totalSupply : Nat = 0;

    // Mint initial supply
    private func mintInitialSupply() {
        let owner = Principal.fromText("aaaaa-aa"); // Replace with actual principal
        let amount : Nat = 1_000_000 * 10 ** Nat8.toNat(decimals);
        balances.put(owner, amount);
        totalSupply := amount;
    };

    // ICRC-1 standard functions

    public shared({ caller }) func icrc1_transfer(args: {
        to: Principal;
        amount: Nat;
    }) : async Result.Result<Nat, Text> {
        let from = caller;
        let to = args.to;
        let amount = args.amount;

        switch (balances.get(from)) {
            case (null) { return #err("Insufficient balance") };
            case (?fromBalance) {
                if (fromBalance < amount + fee) {
                    return #err("Insufficient balance");
                };

                let newFromBalance = fromBalance - amount - fee;
                balances.put(from, newFromBalance);

                let toBalance = Option.get(balances.get(to), 0);
                balances.put(to, toBalance + amount);

                totalSupply := totalSupply - fee;

                return #ok(0); // Transfer index (always 0 in this simple implementation)
            };
        };
    };

    public query func icrc1_balance_of(account: Principal) : async Nat {
        return Option.get(balances.get(account), 0);
    };

    public query func icrc1_total_supply() : async Nat {
        return totalSupply;
    };

    public query func icrc1_name() : async Text {
        return name;
    };

    public query func icrc1_symbol() : async Text {
        return symbol;
    };

    public query func icrc1_decimals() : async Nat8 {
        return decimals;
    };

    public query func icrc1_fee() : async Nat {
        return fee;
    };

    // Initialize the token
    system func preupgrade() {
        Debug.print("Preparing to upgrade. Minting initial supply...");
    };

    system func postupgrade() {
        Debug.print("Upgrade complete. Initial supply minted.");
        mintInitialSupply();
    };
}
