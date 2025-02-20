pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlyCoin is ERC20, Ownable {

    uint public constant INITIAL_TOKENS = 15 * 1e18; // Repartimos 15 tokens en el airdrop
    uint public constant VOTE_COST = 5 * 1e18; // Cada voto vale 5 tokens

    address[5] private voters;
    mapping(address => bool) private hasClaimed;
    mapping(address => bool) private hasVoted;
    mapping(address => bool) private hasDelegatedVote;
    mapping(address => uint256) private voterAmount;

    constructor() ERC20('FlyCoin', 'FLY') Ownable(msg.sender) {
        _mint(msg.sender, ((5*15) * 1e18)); //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 owner
        voters = [
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 
            0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 
            0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 
            0x17F6AD8Ef982297579C203069C1DbfFE4348c372
        ];
    } 

    // Verifica si el sender está en la lista de votantes
    modifier checkVoter(address newVoter)  {
        bool isAllowed = false;
        for(uint256 i = 0; i < voters.length; i++) {
            if(newVoter == voters[i]) {
                isAllowed = true;
                break;
            }
        }
        require(isAllowed, "You are not allowed to vote");
        _;
    }

    modifier checkTokensAmount() {
        require(balanceOf(msg.sender) >= VOTE_COST, "Not enough tokens to vote");
        _;
    }

    event Voted(address indexed voter);

    // Los usuarios pueden reclamar su airdrop si están en la lista inicial y no lo han reclamado aun
    function claim() checkVoter(msg.sender) public {
        require(!hasClaimed[msg.sender], "You have alredy claimed your initial tokens");

        _transfer(owner(), msg.sender, INITIAL_TOKENS); //Transferimos del owner que tiene todos los tokens al sender que está reclamando su airdrop
        hasClaimed[msg.sender] = true;
    }

    // Bloqueamos transferencias entre usuarios
    function transfer(address to, uint256 amount) public override returns(bool) {
        require(msg.sender == owner(), "Transfers between users are not allowed");

        return super.transfer(to, amount);
    }

    // Bloqueamos transferencias entre usuarios
    function transferFrom(address /*from*/, address /*to*/, uint256 /*amount*/) public pure override returns (bool) {
        revert("Transfers between users are not allowed");
    }

    // Función para votar si no lo ha hecho ya con quema de tokens y reducción de tokens del votante. 
    function vote() public checkTokensAmount() {
        require(!hasVoted[msg.sender], "You have already voted");

        hasVoted[msg.sender] = true; // Controlamos quién ha votado
        _burn(msg.sender, VOTE_COST); // Quemamos los tokens
        emit Voted(msg.sender);
    }

    // Hacemos que los votos sean delegables y qué este puede votar 2 veces (su voto y el que le ha delegado el voto)
    function delegateVote(address to_) public checkVoter(to_) checkTokensAmount() {
        require(!hasVoted[msg.sender], "You have already voted");
        require(!hasDelegatedVote[msg.sender], "You have already delegated your vote");
        require(to_ != msg.sender, "You cannot delegate to yourself");
        
        hasDelegatedVote[to_] = true;
        hasVoted[msg.sender] = true; //Quitamos el derecho a voto del sender
        _transfer(msg.sender, to_, VOTE_COST); // Transferimos los tokens al receptor
    }

    // Función para votar cuando tienesun voto delegado
    function voteDelegated() public {
        require(hasDelegatedVote[msg.sender], "You have not received a delegated vote");

        hasDelegatedVote[msg.sender] = false;
        hasVoted[msg.sender] = true;
        _burn(msg.sender, VOTE_COST); //Quemamos los tokens
        emit Voted(msg.sender);
    }

}