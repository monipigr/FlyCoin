// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlyCoin is ERC20, Ownable {

    uint public constant INITIAL_TOKENS = 15 * 1e18; // Initial airdrop amount per voter
    uint public constant VOTE_COST = 5 * 1e18; // Token cost per vote

    address[5] private voters;
    mapping(address => bool) private hasClaimed;
    mapping(address => bool) private hasVoted;
    mapping(address => bool) private hasDelegatedVote;
    mapping(address => uint256) private voterAmount;

    constructor() ERC20('FlyCoin', 'FLY') Ownable(msg.sender) {
        _mint(msg.sender, ((5*15) * 1e18)); // Mint initial supply to contract owner
        voters = [
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 
            0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 
            0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 
            0x17F6AD8Ef982297579C203069C1DbfFE4348c372
        ];
    } 

    // Modifier to ensure the caller is an authorized voter
    modifier checkVoter(address newVoter_)  {
        require(newVoter_ != owner(), "You are the owner of the contract");
        bool isAllowed = false;
        for(uint256 i = 0; i < voters.length; i++) {
            if(newVoter_ == voters[i]) {
                isAllowed = true;
                break;
            }
        }
        require(isAllowed, "You are not allowed to vote");
        _;
    }

    // Modifier to ensure the caller has enough tokens to vote
    modifier checkTokensAmount() {
        require(balanceOf(msg.sender) >= VOTE_COST, "Not enough tokens to vote");
        _;
    }

    event Voted(address indexed voter);

    // Allow eligible voters to claim their initial token allocation
    function claim() checkVoter(msg.sender) public {
        require(!hasClaimed[msg.sender], "You have alredy claimed your initial tokens");

        _transfer(owner(), msg.sender, INITIAL_TOKENS);
        hasClaimed[msg.sender] = true;
    }

    // Restricts token transfers to only allow transfers from the owner
    function transfer(address to_, uint256 amount_) public override returns(bool) {
        require(msg.sender == owner(), "Transfers between users are not allowed");

        return super.transfer(to_, amount_);
    }

    // Blocks token transfers initiated by third parties
    function transferFrom(address /*from*/, address /*to*/, uint256 /*amount*/) public pure override returns (bool) {
        revert("Transfers between users are not allowed");
    }

    // Allows an eligible voter to cast a vote by burning tokens
    function vote() public checkVoter(msg.sender) checkTokensAmount() {
        require(!hasVoted[msg.sender], "You have already voted");

        hasVoted[msg.sender] = true; 
        _burn(msg.sender, VOTE_COST); 
        emit Voted(msg.sender);
    }

    // Hacemos que los votos sean delegables y qué este puede votar 2 veces (su voto y el que le ha delegado el voto)
    function delegateVote(address to_) public checkVoter(to_) checkTokensAmount() {
        require(!hasVoted[msg.sender], "You have already voted");
        require(!hasDelegatedVote[msg.sender], "You have already delegated your vote");
        require(to_ != msg.sender, "You cannot delegate to yourself");
        
        hasDelegatedVote[to_] = true;
        hasVoted[msg.sender] = true; 
        _transfer(msg.sender, to_, VOTE_COST);
    }

    // Allows a voter who received a delegated vote to cast the vote
    function voteDelegated() public {
        require(hasDelegatedVote[msg.sender], "You have not received a delegated vote");

        hasDelegatedVote[msg.sender] = false;
        hasVoted[msg.sender] = true;
        _burn(msg.sender, VOTE_COST);
        emit Voted(msg.sender);
    }

}