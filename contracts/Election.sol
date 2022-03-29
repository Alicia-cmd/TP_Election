pragma solidity ^0.4.12;

// SPDX-License-Identifier: GPL-3.0

import "./Ownable.sol";
import "./SafeMath.sol";
import "./Whitelist.sol";

contract Election is Ownable {

    address _creator;

using SafeMath for uint256;

    //differents types de votes possibles
    enum VoteType {VoteCandidat}
    bool public isVotingInSession;
    
    // Model a Candidate
    struct Candidat{
        address adressCandidat;
        uint number;
        string name;
        uint compteurNbOUI;
        uint voteCount;
    }

    // Model de vote total
    struct TotalVotes{
        uint NbVotesTotal;
    }
    
    address[] votants; //tableau qui recoit les adresses des personnes qui auront le droit de voter 
    mapping(address => bool) public HasVoted;

    //Pour verifier que c'est bien le createur du vote qui appelle une fonction 
    modifier isCreator(){
        if(msg.sender != _creator) throw; 
    }

    //Pour que le createur du vote ajoute un votant
    function addVotant(address adressVotant) public votantMustNotExistYet(adressVotant) isCreator(){
        votants.push(adressVotant);
    }

    // Store accounts that have voted
    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;
    mapping(uint => TotalVotes) public totalvotes;
    // Store Candidates Count
    uint public candidatesCount;
    uint public totalvotesCount;

    Candidat[]  public candidats;

    // voted event
    event endVote(uint number);
    event votedEvent ( uint indexed _candidateId);
    event TotalvotedEvent ( uint indexed _totalvotesId);

    //Ajouter un candidat
    function addCandidate (string memory _name, address _address) public onlyOwner {
            candidatesCount ++;
            candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    // modifier pour ne pas ajouter 2 fois un meme candidat
    modifier candidatMustNotExistYet(){
        for (uint i=0; i<candidats.length; i++)
        {
            if (candidats[i].adressCandidat == msg.sender) throw;
            _;
        }
    }  

    //Supprimer un candidat
    function removeCandidate (string memory _name, address _address) public onlyOwner{
        suicide(msg.sender);
    }

    //Récupérer l'identifiant de l'utilisateur
    function get() public view returns (uint) {
        return address;
    }

    
    function addVote (uint _candidateId, uint _totalvotesId) public {

        //Si le temps est toujours compris dans le temps de vote alors on peut voter
        if (block.timestamp <= 1 days){

            // vérifier que le votant n'a pas déjà voté
            require(!voters[msg.sender]);

            // require a valid candidate
            require(_candidateId > 0 && _candidateId <= candidatesCount);

            // record that voter has voted
            voters[msg.sender] = true;

            // update candidate vote Count
            candidates[_candidateId].voteCount ++;
            //Calcul du nombre total de vote
            totalvotes[_totalvotesId].NbVotesTotal ++;

            // trigger voted event
            emit votedEvent (_candidateId);
            emit TotalvotedEvent (_totalvotesId);
        }
    
    }

}
