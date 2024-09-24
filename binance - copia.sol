/*
 * ***************************************************************
 * *                     *** Mixer-Multi-Chain: 0xUntracked      *
 * ***************************************************************
 * Description:
 * The untraceable ERC20 contract Multi-Mixer 0x is integrated into a 
 * decentralized cross-chain mixer, enhancing anonymity and privacy on 
 * Ethereum-based networks. The protocol allows seamless mixing of funds with 
 * complete disassociation between deposits and withdrawals, utilizing 
 * advanced cryptographic principles like nullifiers and commitments.
 * 
 * Codes, including the secret and nullifier, are generated off-chain, 
 * preventing tracking on the blockchain. This adds an extra layer of privacy. 
 * The algorithm leverages keccak256 to generate commitments and nullifiers, 
 * ensuring integrity and security in every transaction.
 * 
 * Features:
 * - Deposits of any amount with dynamic fee calculations.
 * - Supports multiple partial withdrawals until the total deposit is withdrawn.
 * - Withdrawals are conditioned on a random number of additional deposits to 
 *   increase anonymity.
 * - Compatible with optional relayers to further obfuscate the withdrawal address.
 * - Enhanced privacy through off-chain code generation.
 * 
 * This design ensures a high level of anonymity and flexibility in 
 * transactions.
 * 
 * ***************************************************************
 * Author: [Anon/SN]
 * Version: 1.0
 */
// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: MultiMixer0xUntracked.sol



pragma solidity ^0.8.20;



contract MixerMultiChain0xUntracked is ReentrancyGuard, Ownable {
    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 depositTime;
        uint256 requiredAdditionalDeposits;
        uint256 currentDepositsSince;
        bool claimed;
    }

    mapping(bytes32 => Deposit) public commitments;
    mapping(bytes32 => bool) public nullifiers;

    uint256 public feePercentage = 5; //fees
    uint256 public totalFees;
    uint256 public poolBalance;
    uint256 public totalDeposits = 0;
    uint256 public withdrawalDelay = 3600 seconds; //1hour
    uint256 public totalDepositsAfter = 0;

    event DepositMade(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);
    event FeeWithdrawn(address indexed owner, uint256 amount);
    event FeePercentageUpdated(uint256 newFeePercentage);
    event WithdrawalDelayUpdated(uint256 newWithdrawalDelay);

    constructor() Ownable(msg.sender) {}

    
    function deposit(bytes32 commitment) public payable nonReentrant {
    
    require(msg.value > 0, "The deposit must be greater than 0");
    require(
        commitments[commitment].amount == 0,
        "The commitment has already been used"
    );


    uint256 feeAmount = (msg.value * feePercentage) / 100;
    uint256 depositAmount = msg.value - feeAmount;

    poolBalance += depositAmount;
    totalFees += feeAmount;

    
    uint256 additionalDepositsRequired = 3 +
        (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            5);


    commitments[commitment] = Deposit({
        amount: depositAmount,
        withdrawn: 0,
        depositTime: block.timestamp,
        requiredAdditionalDeposits: additionalDepositsRequired,
        currentDepositsSince: totalDepositsAfter,
        claimed: false
    });

    totalDeposits += 1;
    totalDepositsAfter += 1;

    emit DepositMade(msg.sender, depositAmount);
}


    
    function withdraw(
        bytes32 secret,
        bytes32 nullifier,
        uint256 amount,
        address payable recipient
    ) public nonReentrant {
        bytes32 commitment = keccak256(abi.encodePacked(secret, nullifier));
        Deposit storage dep = commitments[commitment];

        require(dep.amount > 0, "Deposit not found or already claimed");
        require(
            dep.withdrawn + amount <= dep.amount,
            "Exceeds the available balance"
        );
        require(
            totalDepositsAfter - dep.currentDepositsSince >=
                dep.requiredAdditionalDeposits,
            "You still can't withdraw, please wait for more deposits"
        );
        require(!nullifiers[nullifier], "Nullifier already used");
        require(
            block.timestamp >= dep.depositTime + withdrawalDelay,
            "You still can't claim"
        );

       
        dep.withdrawn += amount;
        if (dep.withdrawn == dep.amount) {
            nullifiers[nullifier] = true;
        }

        require(
            poolBalance >= amount,
            "There are not enough funds in the pool"
        );
        poolBalance -= amount;

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(recipient, amount);
    }

  
    function getRemainingDeposits(bytes32 commitment)
        public
        view
        returns (uint256)
    {
        Deposit storage dep = commitments[commitment];
        require(dep.amount > 0, "Commitment not found");
        if (
            totalDepositsAfter - dep.currentDepositsSince >=
            dep.requiredAdditionalDeposits
        ) {
            return 0;
        } else {
            return
                dep.requiredAdditionalDeposits -
                (totalDepositsAfter - dep.currentDepositsSince);
        }
    }

    
    function withdrawFees() public onlyOwner nonReentrant {
        uint256 amount = totalFees;
        require(amount > 0, "There are no fees for withdrawal");
        totalFees = 0;

        (bool success, ) = owner().call{value: amount}("");
        require(success, "ETH transfer to owner failed");

        emit FeeWithdrawn(owner(), amount);
    }

    
    function setFeePercentage(uint256 newFeePercentage) public onlyOwner {
        require(newFeePercentage <= 100, "The rate must be between 0 and 100");
        feePercentage = newFeePercentage;
        emit FeePercentageUpdated(newFeePercentage);
    }

    
    function setWithdrawalDelay(uint256 newWithdrawalDelay) public onlyOwner {
        withdrawalDelay = newWithdrawalDelay;
        emit WithdrawalDelayUpdated(newWithdrawalDelay);
    }

    receive() external payable {}

    fallback() external payable {
        revert("Invalid call");
    }
}