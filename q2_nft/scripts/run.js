const main = async () => {
	// Compile the contract and generate artifact-files
	const nftContractFactory = await hre.ethers.getContractFactory('MyNft');
	// Create local Ethereum network for this contract (destroy after script completion)
	// Every time the contract runs, it will be a fresh blockchain
	const nftContract = await nftContractFactory.deploy();
	// Wait until after the contract is mined & deployed to local blockchain
	await nftContract.deployed();
	// Constructor runs after the contract has been fully deployed
	// nftContract.address gives us the address of the deployed contract
	console.log("Contract deployed to:", nftContract.address);

	// Call the function
	let txn = await nftContract.makeACuteNft()
	// Wait for it to be mined
	await txn.wait()

	// Mint another NFT (for fun... :)
	txn = await nftContract.makeACuteNft()
	// Wait for it to be mined
	await txn.wait()
};

const runMain = async () => {
	try {
		await main();
		process.exit(0);
	} catch (error) {
		console.log(error);
		process.exit(1);
	}
};

runMain();
