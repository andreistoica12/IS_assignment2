pragma solidity ^0.8.0;

// contract Vote {

//     address shareholder;
//     bool vote;

//     constructor(address _shareholder, bool _vote) {
//         shareholder = _shareholder;
//         vote = _vote;
//     }

// }

contract Vote {

    address director;
    string question;
    bool open;

    address[] shareholders;  // TODO can we simplify shareholders and the mapping into one? Given that we need to whitelist addresses.
    mapping(address -> shareholderVote) votes;

    struct shareholderVote {
        bool voted;  // Have to check this, as all mappings are instantiated as a mapping to false otherwise.
        bool vote;
    } 

    constructor(string _question) {
        
        // Sets creator of contract to be the director.
        director = msg.sender;

        // Sets question for the vote.
        question = _question;

        // Opens the vote
        open = true;

    }

    function isShareholder view (address _shareholder) {

    }

    function addShareholder public (address _shareholder) {
        require(msg.sender == director, "Only the director can add shareholders!");

        // Check if shareholder already in the array


        // Append shareholder to array
        shareholders.push(_shareholder);

    }

    function removeShareholder public (address _shareholder) {
        require(msg.sender == director, "Only the director can remove shareholders!");

        // TODO make sure to remove a possible vote too.

    }

    // Allows eligable shareholders to vote by providing their Yes/No (true/false) answer.
    function vote public (bool _decision) {
        // Check if closed.
        require(open == true, "Voting has closed!")

        // Check if in shareholder list.

        // Check if not yet voted.

    }

    // Allows the director to close the poll.
    function close public () {
        require(msg.sender == director, "Only the director can close the vote!");

        // Close vote.
        open = false;

    }

    function result public view () {
        require(open == false, "Only closed votes can have their results checked!")

        // require being a shareholder or owner.

        // Compute result

    }

}
