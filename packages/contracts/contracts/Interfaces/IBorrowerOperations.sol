// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// Common interface for the Trove Manager.
interface IBorrowerOperations {

    // --- Events ---

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address  _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event PAITokenAddressChanged(address _paiTokenAddress);
    event LQTYStakingAddressChanged(address _lqtyStakingAddress);

    event TroveCreated(address indexed _borrower, uint arrayIndex);
    event TroveUpdated(address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);
    event BorrowingFeePaid(address indexed _borrower, uint _PAIFee);

    // --- Functions ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _priceFeedAddress,
        address _sortedTrovesAddress,
        address _paiTokenAddress,
        address _lqtyStakingAddress
    ) external;

    function openTrove(uint _maxFee, uint _PAIAmount, uint _CollAmount, address _upperHint, address _lowerHint) external;

    function addColl(uint _collAmount, address _upperHint, address _lowerHint) external;

    function moveCollateralGainToTrove(address _user, uint _collAmount, address _upperHint, address _lowerHint) external;

    function withdrawColl(uint _collAmount, address _upperHint, address _lowerHint) external;

    function withdrawPAI(uint _maxFee, uint _PAIAmount, address _upperHint, address _lowerHint) external;

    function repayPAI(uint _PAIAmount, address _upperHint, address _lowerHint) external;

    function closeTrove() external;

    function adjustTrove(uint _maxFee, uint _collWithdrawal, uint _collDeposit, uint _debtChange, bool isDebtIncrease, address _upperHint, address _lowerHint) external;

    function claimCollateral() external;

    function getCompositeDebt(uint _debt) external pure returns (uint);
}
