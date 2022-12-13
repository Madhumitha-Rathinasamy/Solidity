// SPDX-License-Identifier: MIT

pragma solidity 0.8.17; 

// Creating a contract
contract hashingFunction {

    struct Values{
        string name;
        string symbol;
        uint8 id;
    }

// creating hash for struct value and values are already given
     function hash() external pure returns (bytes32) {
        // Just compare the output of hashing all fields packed
        Values memory _first;
        _first.name = "mad";
        _first.symbol = "mad";
        _first.id = 12;
        return keccak256(abi.encodePacked(_first.name, _first.symbol, _first.id));
    }

    /**
    * @dev comparing the hash with the given values
    * @param name, symbol, id are given values and
    * value is for hash that we need to compare
     */

    function compareHashing(string memory name_, string memory symbol_, uint8 id_, bytes32 value)external pure returns(bool){
        Values memory _first = Values({
            name : name_,
            symbol : symbol_,
            id : id_});
        return keccak256(abi.encodePacked(_first.name, _first.symbol, _first.id)) == value;
    }

    /**
    * @dev converting string into hash
    * @param word
     */

    function convertHash(string memory _word) external pure returns(bytes32){
        return keccak256(abi.encodePacked(_word));
    }

    /**
    * @dev comparing hash with the word
    * @param word and hashValue
     */

    function comparing(string memory _word, bytes32 hashValue) external pure returns(bool){
        return keccak256(abi.encodePacked(_word)) == hashValue;
    }
}

//  function equals(Example storage _first, Example storage _second) internal view returns (bool) {
//         // Just compare the output of hashing all fields packed
//         return(keccak256(abi.encodePacked(_first.age, _first.name)) == keccak256(abi.encodePacked(_second.age, _second.name)));
//     }