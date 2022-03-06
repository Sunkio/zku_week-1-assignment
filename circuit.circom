pragma circom 2.0.0;

template Main() {
	signal input	x;
	signal input	y;
	//output is always public, so the verifier will know the value without knowing the input values!
	signal output	prod;

// <== is short for prod <-- x*y; prod === x*y;
	prod <== x*y;
}

component main = Main();