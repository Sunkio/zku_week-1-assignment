#! /bin/bash

# Clean-up before new compute
rm merkleTree.r1cs merkleTree.sym merkleTree_* pot* proof.json public.json verification_key.json witness.wtns verifier.sol
rm -r merkleTree_*

# 1 - Compiling the circuit
# --r1cs outputs the constraints in r1cs (= rank-1 constraint system) format; the first step in
# converting an algebraic circuit into a zk-snark => merkleTree.r1cs
# --wasm compiles the circuit to wasm (= WebAssembly code to generate the witness) => merkleTree.wasm
# -- sym outputs witness in sym format (= a symbols file required for debugging and printing the constraint
# system in an annotated mode) => merkleTree.sym
# --c compile the circuit to c => faster, recommended for bigger circuits 
circom merkleTree.circom --r1cs --wasm --sym # --c

# Check some basic info about the circuit (for safety, not mandatory)
snarkjs info -r merkleTree.r1cs

# 2 - Computing the witness
# Option 1: with WebAssembly
# Copy the input file to the new merkleTree_js directory
cp input.json merkleTree_js

# Go inside the merkleTree_js directory and generate the witness.wtns
cd merkleTree_js
node generate_witness.js merkleTree.wasm input.json witness.wtns

# Option 2: with C++
# cp input.json merkleTree_cpp
# cd merkleTree_cpp
# make
# ./merkleTree input.json witness.wtns

# Copy the witness.wtns to the parent directory & change directory to the parent
cp witness.wtns ../
cd ..

# 3 - Proving the circuit
# Start a new powers of tau ceremony
snarkjs powersoftau new bn128 13 pot13_0000.ptau -v

# Contribute to the ceremony
snarkjs powersoftau contribute pot13_0000.ptau pot13_0001.ptau --name="First contribution" -v

# Start generating phase 2
snarkjs powersoftau prepare phase2 pot13_0001.ptau pot13_final.ptau -v

# Generate the .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup merkleTree.r1cs pot13_final.ptau merkleTree_0000.zkey

# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute merkleTree_0000.zkey merkleTree_0001.zkey --name="1st Contributor Name" -v

# Export the verification key
snarkjs zkey export verificationkey merkleTree_0001.zkey verification_key.json

# Generate a zk-proof associated to the circuit and the witness.
# This creates a Groth16 proof and the proof.json and public.json as output files.
snarkjs groth16 prove merkleTree_0001.zkey witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# 4 - Verifying from a Smart Contract
# Generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier merkleTree_0001.zkey verifier.sol

# Generate and print parameters of call
snarkjs generatecall