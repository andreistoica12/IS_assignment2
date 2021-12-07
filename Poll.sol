// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Poll {

    address public director;
    address[] shareholders;

    // Question[] questions;

    // struct Vote {
    //     bool voted;    // If true, that person already voted.
    //     bool vote;     // Answer recorded for the vote.
    // }

    // struct Question {
    //     string name;                            // Complete question string.
    //     mapping(address => Vote) public Votes;  // Accumulated votes
    // }

    /** 
     * @dev Create a new Poll.
     */
    constructor() {
        
        // Simply sets the director of this Poll - grants admin privileges.
        director = msg.sender;

    }

    /**
    * @dev Checks if address is eligible to vote. Also returns the index of the shareholder in
    * the array. If the address cannot be found, returns -1.
    **/
    function isShareholder(address _shareholder) public view returns (bool success, uint shareholderIndex) {

        // Only search if there is a list to search.
        if (shareholders.length > 0) {

            // Search for shareholder index;
            for (uint i=0; i<shareholders.length; i++) {
                if (shareholders[i] == _shareholder) {
                    return (true, i);
                }
            }
        }

        // Base case - shareholder not found.
        return (false, 0);

    }

    function addShareholder(address _shareholder) public {
        require(msg.sender == director, "Only the director can add shareholders!");

        // Only add new addresses.
        (bool inList, ) = isShareholder(_shareholder);
        require(!inList, "Address already a shareholder!");

        // Update address to shareholder in mapping.
        shareholders.push(_shareholder);

    }

    function removeShareholder(address _shareholder) public  {
        require(msg.sender == director, "Only the director can remove shareholders!");

        // Only remove known addresses.
        (bool inList, uint index) = isShareholder(_shareholder);
        require(inList, "Address not a shareholder!"); // This also checks for an empty list!

        // Remove address from shareholder mapping by copying over last value. This stops gaps from forming.
        shareholders[index] = shareholders[shareholders.length-1];

        // Then, remove last value to delete duplicates.
        shareholders.pop();

        // TODO make sure to remove a possible vote too.

    }

    // // Allows eligable shareholders to vote by providing their Yes/No (true/false) answer.
    // function vote public (bool _decision) {
    //     // Check if closed.
    //     require(open == true, "Voting has closed!")

    //     // Check if in shareholder list.

    //     // Check if not yet voted.

    // }

    // // Allows the director to close the poll.
    // function close public () {
    //     require(msg.sender == director, "Only the director can close the vote!");

    //     // Close vote.
    //     open = false;

    // }

    // function result public view () {
    //     require(open == false, "Only closed votes can have their results checked!")

    //     // require being a shareholder or owner.

    //     // Compute result

    // }



}
