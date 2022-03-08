pragma circom 2.0.0;

// Import the MiMCsponge hash function from circomlib
include "circomlib/circuits/mimcsponge.circom";

template MerkleTree(totalLeaves) {
    signal input leaves[totalLeaves];
    signal output merkleRoot;
    var totalNodes = totalLeaves * 2 - 1;
	var firstLeavePos = totalLeaves - 1;
    component treeNodes[totalNodes];
	signal treeHashes[totalNodes];


    // For-Loop to create a hash for every node in the Merkle Tree
	// The Merkle tree starts with position 0 at the root node which is why the leaves have the
	// highest position count in the tree even though their hashes need to be computed first
    for(var i = totalNodes - 1; i >= 0; i--) {
        // Compute the hashes of the leaves
        if(i >= firstLeavePos) {
			// 1 input and 1 output as parameters for MiMCSponge because the leave hash gets created only from the leave data block
            treeNodes[i] = MiMCSponge(1, 220, 1);
            treeNodes[i].k <== 0;
            // Input to MiMCSponge to compute the hash of the leaf - we iterate through our input leaves array
			var j = 0;
            treeNodes[i].ins[0] <== leaves[j];
			j++;
        } else {
            // If the node is not a leaf (= branch/inner node), we compute the hash of its 2 children
			// MiMCSponge now needs to take two inputs
            treeNodes[i] = MiMCSponge(2, 220, 1);
            treeNodes[i].k <== 0;
            // Input 1 to MiMCSponge to compute the hash of the left child
            treeNodes[i].ins[0] <== treeHashes[2 * i + 2];
            // Input 2 to MiMCsponge to compute the hash of the right child
            treeNodes[i].ins[1] <== treeHashes[2 * i + 1];
        }
        // Update the merkle tree at position i with the computed hash
        treeHashes[i] <== treeNodes[i].outs[0];
    }
    // Outputs the hash of the root which is at position 0 in the Merkle tree
    merkleRoot <== treeHashes[0];
}

// Input signals are private by default, but can be declared public when defining the main component (output signals are always public)
component main {public [leaves]} = MerkleTree(4); 