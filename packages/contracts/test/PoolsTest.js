const StabilityPool = artifacts.require("./StabilityPool.sol")
const ActivePool = artifacts.require("./ActivePool.sol")
const DefaultPool = artifacts.require("./DefaultPool.sol")
const NonPayable = artifacts.require("./NonPayable.sol")
const MockDAI = artifacts.require("./ERC20Mock.sol")

const { BigNumber } = require("ethers")
const testHelpers = require("../utils/testHelpers.js")

const th = testHelpers.TestHelper
const dec = th.dec

const _minus_1_Ether = web3.utils.toWei('-1', 'ether')

contract('StabilityPool', async accounts => {
  /* mock* are EOA’s, temporarily used to call protected functions.
  TODO: Replace with mock contracts, and later complete transactions from EOA
  */
  let stabilityPool

  const [owner, alice, bob] = accounts;

  beforeEach(async () => {
    stabilityPool = await StabilityPool.new()
    const mockActivePoolAddress = (await NonPayable.new()).address
    const dumbContractAddress = (await NonPayable.new()).address
    await stabilityPool.setAddresses(dumbContractAddress, dumbContractAddress, mockActivePoolAddress, dumbContractAddress, dumbContractAddress, dumbContractAddress, dumbContractAddress)
  })

  it('getETH(): gets the recorded ETH balance', async () => {
    const recordedETHBalance = await stabilityPool.getETH()
    assert.equal(recordedETHBalance, 0)
  })

  it('getTotalLUSDDeposits(): gets the recorded LUSD balance', async () => {
    const recordedETHBalance = await stabilityPool.getTotalLUSDDeposits()
    assert.equal(recordedETHBalance, 0)
  })
})

contract('ActivePool', async accounts => {

  let activePool, mockBorrowerOperations, dai;

  const [owner, alice, bob] = accounts;
  beforeEach(async () => {
    activePool = await ActivePool.new()
    mockBorrowerOperations = await NonPayable.new()
    dai = await MockDAI.new(
      "DAI Stablecoin",
      "DAI",
      owner,
      BigNumber.from("1000")
    )
    const dumbContractAddress = (await NonPayable.new()).address
    await activePool.setAddresses(mockBorrowerOperations.address, dumbContractAddress, dumbContractAddress, dumbContractAddress, dai.address)
  })

  it('erc20TokenAddress(): is set correctly', async () => {
    const erc20CollateralAddress = await activePool.getERC20TokenAddress();
    assert.equal(erc20CollateralAddress, dai.address);
  })

  it('getERC20Balance(): gets the recorded ERC20 collateral balance', async () => {
    const recordedERC20Balance = await activePool.getERC20Coll()
    assert.equal(recordedERC20Balance, 0);
  });

  // it('getETH(): gets the recorded ETH balance', async () => {
  //   const recordedETHBalance = await activePool.getETH()
  //   assert.equal(recordedETHBalance, 0)
  // })

  it('getLUSDDebt(): gets the recorded LUSD balance', async () => {
    const recordedLUSDBalance = await activePool.getLUSDDebt()
    assert.equal(recordedLUSDBalance, 0)
  })
 
  it('increaseLUSD(): increases the recorded LUSD balance by the correct amount', async () => {
    const recordedLUSD_balanceBefore = await activePool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceBefore, 0)

    // await activePool.increaseLUSDDebt(100, { from: mockBorrowerOperationsAddress })
    const increaseLUSDDebtData = th.getTransactionData('increaseLUSDDebt(uint256)', ['0x64'])
    const tx = await mockBorrowerOperations.forward(activePool.address, increaseLUSDDebtData)
    assert.isTrue(tx.receipt.status)
    const recordedLUSD_balanceAfter = await activePool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceAfter, 100)
  })

  // Decrease
  it('decreaseLUSD(): decreases the recorded LUSD balance by the correct amount', async () => {
    // start the pool on 100 wei
    //await activePool.increaseLUSDDebt(100, { from: mockBorrowerOperationsAddress })
    const increaseLUSDDebtData = th.getTransactionData('increaseLUSDDebt(uint256)', ['0x64'])
    const tx1 = await mockBorrowerOperations.forward(activePool.address, increaseLUSDDebtData)
    assert.isTrue(tx1.receipt.status)

    const recordedLUSD_balanceBefore = await activePool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceBefore, 100)

    //await activePool.decreaseLUSDDebt(100, { from: mockBorrowerOperationsAddress })
    const decreaseLUSDDebtData = th.getTransactionData('decreaseLUSDDebt(uint256)', ['0x64'])
    const tx2 = await mockBorrowerOperations.forward(activePool.address, decreaseLUSDDebtData)
    assert.isTrue(tx2.receipt.status)
    const recordedLUSD_balanceAfter = await activePool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceAfter, 0)
  })

  it('receiveERC20(): it receives ERC20 collateral and updates the recorded ERC20 balance by the correct amount', async () => {

    // Setup
    await dai.mint(mockBorrowerOperations.address, 100);

    const approveData = th.getTransactionData('approve(address,uint256)', [activePool.address, '0x64']);
    await mockBorrowerOperations.forward(dai.address, approveData);

    const receiveER20Data = th.getTransactionData('receiveERC20(uint256)', ['0x64']);
    const tx1 = await mockBorrowerOperations.forward(activePool.address, receiveER20Data);

    const recordedERC20Balance = await activePool.getERC20Coll()
    assert.equal(recordedERC20Balance, 100);

  })

  it('sendERC20(): decreases the recorded ERC20 balance by the correct amount', async () => {

    // Setup
    await dai.mint(mockBorrowerOperations.address, 600);

    // Aprove ActivePool
    const approveData = th.getTransactionData('approve(address,uint256)', [activePool.address, '0x64']);
    await mockBorrowerOperations.forward(dai.address, approveData);

    // Fund ActivePool
    const receiveER20Data = th.getTransactionData('receiveERC20(uint256)', ['0x64']);
    const tx1 = await mockBorrowerOperations.forward(activePool.address, receiveER20Data);

    // Execute Test (Send ERC20 gem to Bob)
    const sendERC20Data = th.getTransactionData('sendERC20(address,uint256)', [bob, '0x64']);
    const tx2 = await mockBorrowerOperations.forward(activePool.address, sendERC20Data);

    // Verify Results

    // Bob's should have received the ERC20 sent
    const bobsBalance = await dai.balanceOf(bob);
    assert(bobsBalance, 100);

    // ActivePool Balance should be now zero
    const recordedERC20Balance = await activePool.getERC20Coll()
    assert.equal(recordedERC20Balance, 0);

  })

  // send raw ether
  // it('sendETH(): decreases the recorded ETH balance by the correct amount', async () => {
  //   // setup: give pool 2 ether
  //   const activePool_initialBalance = web3.utils.toBN(await web3.eth.getBalance(activePool.address))
  //   assert.equal(activePool_initialBalance, 0)
  //   // start pool with 2 ether
  //   //await web3.eth.sendTransaction({ from: mockBorrowerOperationsAddress, to: activePool.address, value: dec(2, 'ether') })
  //   const tx1 = await mockBorrowerOperations.forward(activePool.address, '0x', { from: owner, value: dec(2, 'ether') })
  //   assert.isTrue(tx1.receipt.status)

  //   const activePool_BalanceBeforeTx = web3.utils.toBN(await web3.eth.getBalance(activePool.address))
  //   const alice_Balance_BeforeTx = web3.utils.toBN(await web3.eth.getBalance(alice))

  //   assert.equal(activePool_BalanceBeforeTx, dec(2, 'ether'))

  //   // send ether from pool to alice
  //   //await activePool.sendETH(alice, dec(1, 'ether'), { from: mockBorrowerOperationsAddress })
  //   const sendETHData = th.getTransactionData('sendETH(address,uint256)', [alice, web3.utils.toHex(dec(1, 'ether'))])
  //   const tx2 = await mockBorrowerOperations.forward(activePool.address, sendETHData, { from: owner })
  //   assert.isTrue(tx2.receipt.status)

  //   const activePool_BalanceAfterTx = web3.utils.toBN(await web3.eth.getBalance(activePool.address))
  //   const alice_Balance_AfterTx = web3.utils.toBN(await web3.eth.getBalance(alice))

  //   const alice_BalanceChange = alice_Balance_AfterTx.sub(alice_Balance_BeforeTx)
  //   const pool_BalanceChange = activePool_BalanceAfterTx.sub(activePool_BalanceBeforeTx)
  //   assert.equal(alice_BalanceChange, dec(1, 'ether'))
  //   assert.equal(pool_BalanceChange, _minus_1_Ether)
  // })
})

contract('DefaultPool', async accounts => {
 
  let defaultPool, mockTroveManager, mockActivePool, dai

  const [owner, alice] = accounts;
  beforeEach(async () => {
    defaultPool = await DefaultPool.new()
    mockTroveManager = await NonPayable.new()
    mockActivePool = await NonPayable.new()
    dai = await MockDAI.new(
      "DAI Stablecoin",
      "DAI",
      owner,
      BigNumber.from("1000")
    )
    await defaultPool.setAddresses(mockTroveManager.address, mockActivePool.address, dai.address)
  })

  it('getERC20Coll(): gets the recorded ERC20 Collateral balance', async () => {
    const recordedETHBalance = await defaultPool.getERC20Coll()
    assert.equal(recordedETHBalance, 0)
  })

  it('getLUSDDebt(): gets the recorded LUSD balance', async () => {
    const recordedETHBalance = await defaultPool.getLUSDDebt()
    assert.equal(recordedETHBalance, 0)
  })
 
  it('increaseLUSD(): increases the recorded LUSD balance by the correct amount', async () => {
    const recordedLUSD_balanceBefore = await defaultPool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceBefore, 0)

    // await defaultPool.increaseLUSDDebt(100, { from: mockTroveManagerAddress })
    const increaseLUSDDebtData = th.getTransactionData('increaseLUSDDebt(uint256)', ['0x64'])
    const tx = await mockTroveManager.forward(defaultPool.address, increaseLUSDDebtData)
    assert.isTrue(tx.receipt.status)

    const recordedLUSD_balanceAfter = await defaultPool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceAfter, 100)
  })
  
  it('decreaseLUSD(): decreases the recorded LUSD balance by the correct amount', async () => {
    // start the pool on 100 wei
    //await defaultPool.increaseLUSDDebt(100, { from: mockTroveManagerAddress })
    const increaseLUSDDebtData = th.getTransactionData('increaseLUSDDebt(uint256)', ['0x64'])
    const tx1 = await mockTroveManager.forward(defaultPool.address, increaseLUSDDebtData)
    assert.isTrue(tx1.receipt.status)

    const recordedLUSD_balanceBefore = await defaultPool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceBefore, 100)

    // await defaultPool.decreaseLUSDDebt(100, { from: mockTroveManagerAddress })
    const decreaseLUSDDebtData = th.getTransactionData('decreaseLUSDDebt(uint256)', ['0x64'])
    const tx2 = await mockTroveManager.forward(defaultPool.address, decreaseLUSDDebtData)
    assert.isTrue(tx2.receipt.status)

    const recordedLUSD_balanceAfter = await defaultPool.getLUSDDebt()
    assert.equal(recordedLUSD_balanceAfter, 0)
  })

  it("receiveERC20(): receive ERC20 from ActivePool and increment local ERC20 tracker", async () => {
    // Setup
    await dai.mint(mockActivePool.address, 100);

    const approveData = th.getTransactionData('approve(address,uint256)', [defaultPool.address, '0x64']);
    await mockActivePool.forward(dai.address, approveData);

    // Preconditions
    const before_ERC20RecordedBalance = await defaultPool.getERC20Coll()
    assert.equal(before_ERC20RecordedBalance, 0)

    // Execute 
    const receiveER20Data = th.getTransactionData('receiveERC20(uint256)', ['0x64']);
    const tx1 = await mockActivePool.forward(defaultPool.address, receiveER20Data);

    // Verify 
    const recordedERC20Balance = await defaultPool.getERC20Coll()
    assert.equal(recordedERC20Balance, 100);

  });

  it("sendERC20ToActivePool(): sends ERC20 tokens to ActivePool and records new balance in local tracker correctly", async () => {

    // Setup
    await dai.mint(mockActivePool.address, 100);

    const approveData = th.getTransactionData('approve(address,uint256)', [defaultPool.address, '0x64']);
    await mockActivePool.forward(dai.address, approveData);

    const receiveER20Data = th.getTransactionData('receiveERC20(uint256)', ['0x64']);
    const tx1 = await mockActivePool.forward(defaultPool.address, receiveER20Data);

    // Preconditions
    const before_defaultPoolRecordedBalance = await defaultPool.getERC20Coll()
    assert.equal(before_defaultPoolRecordedBalance, 100);

    // Execute

    const sendERC20ToActivePoolData = th.getTransactionData('sendERC20ToActivePool(uint256)', ['0x64'])
    const tx2 = await mockTroveManager.forward(defaultPool.address, sendERC20ToActivePoolData)

    // Verify

    const after_defaultPoolRecordedBalance = await defaultPool.getERC20Coll()
    assert.equal(after_defaultPoolRecordedBalance, 0);

  })

  // send raw ether
  // it('sendETHToActivePool(): decreases the recorded ETH balance by the correct amount', async () => {
  //   // setup: give pool 2 ether
  //   const defaultPool_initialBalance = web3.utils.toBN(await web3.eth.getBalance(defaultPool.address))
  //   assert.equal(defaultPool_initialBalance, 0)

  //   // start pool with 2 ether
  //   //await web3.eth.sendTransaction({ from: mockActivePool.address, to: defaultPool.address, value: dec(2, 'ether') })
  //   const tx1 = await mockActivePool.forward(defaultPool.address, '0x', { from: owner, value: dec(2, 'ether') })
  //   assert.isTrue(tx1.receipt.status)

  //   const defaultPool_BalanceBeforeTx = web3.utils.toBN(await web3.eth.getBalance(defaultPool.address))
  //   const activePool_Balance_BeforeTx = web3.utils.toBN(await web3.eth.getBalance(mockActivePool.address))

  //   assert.equal(defaultPool_BalanceBeforeTx, dec(2, 'ether'))

  //   // send ether from pool to alice
  //   //await defaultPool.sendETHToActivePool(dec(1, 'ether'), { from: mockTroveManagerAddress })
  //   const sendETHData = th.getTransactionData('sendETHToActivePool(uint256)', [web3.utils.toHex(dec(1, 'ether'))])
  //   await mockActivePool.setPayable(true)
  //   const tx2 = await mockTroveManager.forward(defaultPool.address, sendETHData, { from: owner })
  //   assert.isTrue(tx2.receipt.status)

  //   const defaultPool_BalanceAfterTx = web3.utils.toBN(await web3.eth.getBalance(defaultPool.address))
  //   const activePool_Balance_AfterTx = web3.utils.toBN(await web3.eth.getBalance(mockActivePool.address))

  //   const activePool_BalanceChange = activePool_Balance_AfterTx.sub(activePool_Balance_BeforeTx)
  //   const defaultPool_BalanceChange = defaultPool_BalanceAfterTx.sub(defaultPool_BalanceBeforeTx)
  //   assert.equal(activePool_BalanceChange, dec(1, 'ether'))
  //   assert.equal(defaultPool_BalanceChange, _minus_1_Ether)
  // })
})

contract('Reset chain state', async accounts => {})
