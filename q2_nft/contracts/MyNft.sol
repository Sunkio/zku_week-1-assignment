// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// Import OpenZeppelin contract to implement the NFT standard. We'll put our own logic on top of it.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// Import an OpenZeppelin contract that will help us count our tokenIDs
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
// Import fuctions from the Base64 helper contract
import { Base64 } from "./libraries/Base64.sol";

// "is" keyword to inherit the ERC721URIStorage contract that we imported via openzeppelin
// that means, that wi inherit the contract's methods.
contract MyNft is ERC721URIStorage{
	// inherited via openzeppelin Counters contract; to keep trac of tokenIDs
	using Counters for Counters.Counter;
	// _tokenIDs to keep track of the NFTs unique identifier; automatically initialized with 0
	// It's a state variable (= value gets stored on the contract directly)
	Counters.Counter private _tokenIds;

  	// baseSvg is a variable for all the NFTs to use
  	string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='pink' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  	// Create three arrays, each with their own theme of random words.
	string[] firstWords = ["Cute", "Adorable", "Gorgeous", "Disarming", "Endearing", "Darling"];
	string[] secondWords = ["Little", "Precious", "Cunning", "Beguiling", "Artful", "Cagy"];
	string[] thirdWords = ["Chicken", "Bunny", "Panda", "Koala", "Kitten", "Duckling"];

	// To pass the name of the NFT and its symbol
    constructor() ERC721 ("CuteNFT", "Cute") {
        console.log("This is my cute NFT contract!");
    }

	// Functions to randomly pick a word from each of the 3 arrays.
  	function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    	// Seed the random generator: There's basically no real randomness on the blockchain so I combine the first 
		// word with the tokinID as a string to create my source of "randomness" (it's not real randomness, of course, but close enough)
    	uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    	rand = rand % firstWords.length;
    	return firstWords[rand];
  	}

  	function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
		uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
		rand = rand % secondWords.length;
		return secondWords[rand];
  	}

	function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
		uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
		rand = rand % thirdWords.length;
		return thirdWords[rand];
	}

	function random(string memory input) internal pure returns (uint256) {
		return uint256(keccak256(abi.encodePacked(input)));
	}

	// Function for the user to get their NFT
	function makeACuteNft() public {
		// Get current tokenID (starts at 0)
		uint256 newItemId = _tokenIds.current();
		
		// We go and randomly grab one word from each of the three arrays.
		string memory first = pickRandomFirstWord(newItemId);
		string memory second = pickRandomSecondWord(newItemId);
		string memory third = pickRandomThirdWord(newItemId);
		string memory combinedWord = string(abi.encodePacked(first, second, third));

		// Concatenate all strings, and then close the <text> and <svg> tags.
		string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));
		
		// Get all the JSON metadata in place and base64 encode it.
		string memory json = Base64.encode(
			bytes(
				string(
					abi.encodePacked(
						'{"name": "',
						// Set the title of our NFT as the generated word.
						combinedWord,
						'", "description": "A collection of cute NFTs", "image": "data:image/svg+xml;base64,',
						// Add data:image/svg+xml;base64 and then append the base64 encode our svg.
						Base64.encode(bytes(finalSvg)),
						'"}'
					)
				)
			)
		);

		// Prepend data:application/json;base64, to our data.
		string memory finalTokenUri = string(
			abi.encodePacked("data:application/json;base64,", json)
		);
				
		console.log("\n--------------------");
		console.log(finalTokenUri);
		console.log("--------------------\n");

		// Mint the NFT to the sender
		// msg.sender is a variable that Solidity provides; gives easy access to the public address
		// of the person calling the contract
		_safeMint(msg.sender, newItemId);
	
		// Set the NFTs unique identifier along with the data for the unique identifier
		_setTokenURI(newItemId, "finalTokenUri");

		// See when the NFT is minted & to who
		console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

		// Increment the counter for when the next NFT is minted (from OpenZeppelin)
		_tokenIds.increment();
	}
}