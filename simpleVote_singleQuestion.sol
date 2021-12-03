pragma solidity ^0.8.0;


contract Vote {

    address director;
    string question;
    bool open;

    // // we store all shareholders in an array
    // address[] shareholders;  // TODO can we simplify shareholders and the mapping into one? Given that we need to whitelist addresses.
    
    // OPTION 2 - we store all shareholders in a mapping (a hash map-like structure)
    // for quicker access and less computational load 
    mapping(address => bool) shareholders;
    
    mapping(address => shareholderVote) votes;

    uint public totalVotes;
    uint public positiveVotes;

    

    struct shareholderVote {
        bool voted;  // Have to check this, as all mappings are instantiated as a mapping to false otherwise.
        bool vote;
    }

    constructor(string memory _question) {
        
        // Sets creator of contract to be the director.
        director = msg.sender;

        // Sets question for the vote.
        question = _question;

        // Opens the vote
        open = true;

    }


    // function which checks if a given shareholder 
    // already exists in the mapping of shareholders - OPTION 2
    function isShareholder(address _shareholder) public returns (bool) {
        return shareholders[_shareholder];
    }

    function addShareholder(address _shareholder) public {
        require(msg.sender == director, "Only the director can add shareholders!");

        // Check if shareholder already in the array


        // Check if shareholder already in the mapping - OPTION 2
        require(isShareholder(_shareholder) == false, "Shareholder already in the mapping!");


        // // Append shareholder to array
        // shareholders.push(_shareholder);

        // Append shareholder to mapping - OPTION 2
        shareholders[_shareholder] = true;

    }

    function removeShareholder(address _shareholder) public {
        require(msg.sender == director, "Only the director can remove shareholders!");

        // Check if shareholder already in the mapping - OPTION 2
        require(isShareholder(_shareholder) == true, "Shareholder is not in our database!");

        totalVotes -= 1;
        if (votes[_shareholder].vote == true) {
            positiveVotes -= 1;
        }

        // TODO make sure to remove a possible vote too.
        delete votes[_shareholder];

        // delete the shareholder from the shareholders mapping
        delete shareholders[_shareholder];


    }

    // Allows eligable shareholders to vote by providing their Yes/No (true/false) answer.
    function vote(address _shareholder, bool _decision) public {
        // Check if closed.
        require(open == true, "Voting has closed!");

        // Check if in shareholder list.
        require(isShareholder(_shareholder) == true, "Shareholder is not in our database!");

        // Check if not yet voted.
        require(votes[_shareholder].voted == false, "Each shareholder can vote only once!");

        // if all conditions from above are met, take the vote into consideration
        votes[_shareholder].vote = _decision;

        // increase the number of total votes
        totalVotes += 1;

        // if the vote is positive, increment the positiveVotes variable
        if (_decision == true) {
            positiveVotes += 1;
        }

    }

    // Allows the director to close the poll.
    function close() public {
        require(msg.sender == director, "Only the director can close the vote!");

        // Close vote.
        open = false;

    }

    function result() public returns (bool) {
        require(open == false, "Only closed votes can have their results checked!");

        // require being a shareholder or owner.
        require(msg.sender == director || isShareholder(msg.sender) == true, "Either the director or the shareholders can access the result!");

        // Compute result
        return (2 * positiveVotes > totalVotes);

    }

}