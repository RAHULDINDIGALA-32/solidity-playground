// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

error Voting__OnlyVotersAllowed();
error Voting__ProposalAlreadyExecuted();

/**
 * @title Basic Governance Smart Contract
 * @author Rahul Dindigala
 * @notice This contract allows a set of predefined voters to create proposals, cast votes, and execute proposals once they reach a certain threshold of 'yes' votes.
 */

contract Voting {

    /*
     * @dev The contract uses an enum to track vote states and a struct to represent proposals.
     */
    enum VoteStates {Absent, Yes, No}

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool isExecuted;
        uint executionThreshold; // number of 'yes' votes required for execution
        mapping (address => VoteStates) voteStates; // tracks voters vote status
    }

    Proposal[] public proposals;
    mapping (address => bool) voters; // access time: O(1)

    event ProposalCreated(uint indexed proposalId);
    event VoteCast(uint indexed proposalId, address indexed voter);
    event ExecuteProposal(uint indexed proposalId);

    // modifiers
    modifier onlyVoters() {
        if(!voters[msg.sender]){
            revert Voting__OnlyVotersAllowed();
        }
        _;
    }


    // Functions
    // constructor
    constructor(address[] memory _voters) {
        for(uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
        voters[msg.sender] = true;
    }

    // external functions
    function newProposal(address _target, bytes calldata _data) external onlyVoters {
        Proposal storage proposal = proposals.push();

        proposal.target = _target;
        proposal.data = _data;
        proposal.executionThreshold = 10; // hardcoded for simplicity

        emit ProposalCreated(proposals.length-1);
    }

    function castVote(uint _proposalId, bool vote) external onlyVoters {
         Proposal storage proposal = proposals[_proposalId];
         VoteStates prevVote = proposal.voteStates[msg.sender];

         if(prevVote == VoteStates.Yes){
             proposal.yesCount--;
         }

          if(prevVote == VoteStates.No){
             proposal.noCount--;
         }

         if(vote){
             proposal.yesCount++;
             proposal.voteStates[msg.sender] = VoteStates.Yes;
         }
         else {
             proposal.noCount++;
              proposal.voteStates[msg.sender] = VoteStates.No;
        }

        emit VoteCast(_proposalId, msg.sender);

        if(proposal.yesCount >= proposal.executionThreshold) {
            executeProposal(_proposalId);
        }
       
    }

    // internal functions
    function executeProposal(uint _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];

        if(proposal.isExecuted){
            revert Voting__ProposalAlreadyExecuted();
        }

        (bool success, ) = (proposal.target).call(proposal.data);
        require(success);

        proposal.isExecuted = true;
        emit ExecuteProposal(_proposalId);
    }

    
}
