// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract Poll {

    address director;
    address[] shareholders;

    Question[] questions;

    struct Question {
        string name;                        // Question identifier.
        address[] voted;                    // Mapping of addresses that have voted, if true - they've voted.
        int voteCount;                      // Accumulated votes. Positive non-zero values represent accepted questions, negative values rejected ones.
        bool open;                          // Open status of question.
    }

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
    function isShareholder(address _shareholder) internal view returns (bool success, uint shareholderIndex) {

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

    /** 
    * @dev Adds an address to the shareholders array, it is isn't already in there.
    **/
    function addShareholder(address _shareholder) public {
        require(msg.sender == director, "Only the director can add shareholders!");

        // Only add new addresses.
        (bool inList, ) = isShareholder(_shareholder);
        require(!inList, "Address already a shareholder!");

        // Update address to shareholder in mapping.
        shareholders.push(_shareholder);

    }

    /** 
    * @dev Removes an address from the shareholders array, if it exists. Cleans up the array
    * so there are no gaps.
    **/
    function removeShareholder(address _shareholder) public  {
        require(msg.sender == director, "Only the director can remove shareholders!");

        // Only remove known addresses.
        (bool inList, uint index) = isShareholder(_shareholder);
        require(inList, "Address not a shareholder!"); // This also checks for an empty list!

        // Remove address from shareholder mapping by copying over last value. This stops gaps from forming.
        shareholders[index] = shareholders[shareholders.length-1];

        // Then, remove last value to delete duplicates.
        shareholders.pop();

    }

    /** 
    * @dev Adds an address to the shareholders array, it is isn't already in there.
    **/
    function addQuestion(string memory _question) public {
        require(msg.sender == director, "Only the director can add questions!");

        // Create question from input.
        Question memory q;
        q.name = _question;
        q.open = true;

        // Push to question array - stores in persistent storage.
        questions.push(q);

    }

    function hasVotedOn(Question memory _question, address _shareholder) internal pure returns (bool){

        // Only search if there is a list to search.
        if (_question.voted.length > 0) {

            // Search for shareholder index;
            for (uint i=0; i<_question.voted.length; i++) {
                if (_question.voted[i] == _shareholder) {
                    return true;
                }
            }
        }

        // Base case - shareholder not found.
        return false;

    }

    function voteOnQuestion(uint _question, bool _decision) public {
        
        // Only allow shareholders to vote.
        (bool exists, ) = isShareholder(msg.sender);
        require(exists, "Address not a shareholder!");

        // Only allow shareholder to vote once.
        require(!hasVotedOn(questions[_question], msg.sender), "Shareholder has already voted on this question!");

        // Only allow voting on open questions.
        require(_question < questions.length, "Selected question is out of bounds of question array.");
        require(questions[_question].open, "Question is closed, you cannot vote.");

        // Actual voting.
        if (_decision) {
            questions[_question].voteCount++;
        } else {
            questions[_question].voteCount--;
        }

        // Remember that this shareholder voted for this question.
        questions[_question].voted.push(msg.sender);

    }

    function closeQuestion (uint _question) public {
        require(msg.sender == director, "Only the director can close the vote!");

        // Only allow closing of open questions.
        require(_question < questions.length, "Selected question is out of bounds of question array.");
        require(questions[_question].open, "Question is already closed.");

        // Close vote.
        questions[_question].open = false;

    }

    function viewResultOf(uint _question) public view returns (string memory q){

        if (msg.sender != director) {

            // Only shareholders can see the results.
            (bool exists, ) = isShareholder(msg.sender);
            require(exists, "You are not a shareholder and cannot see the results.");
            
            // Only allow closed questions to be viewed.
            require(!questions[_question].open, "Viewing results require the question to be closed.");
        }

        // Return the actual question object. This contains the voteCount, showing the result.
        require(_question < questions.length, "Selected question is out of bounds of question array.");
        
        // When voteCount == 0 (i.e. equal amount of yes and no).
        q = "Majority votes indecisive.";
        
        // More yes than no answers.
        if (questions[_question].voteCount > 0) {
            q = "Majority votes yes";
        }

        // More no than yes.
        if (questions[_question].voteCount < 0) {
            q = "Majority votes no";
        }
        
    }

}
