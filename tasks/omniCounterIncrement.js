const ENDPOINT_IDS = require('../constants/endpointIds.json')
const {getDeploymentAddresses} = require('../utils/readStatic')

module.exports = async function (taskArgs, hre) {
    const dstChainId = ENDPOINT_IDS[taskArgs.targetNetwork]
    // console.log(`dstChainId: ${dstChainId}`)
    console.log(`[destination] OmniCounter`, getDeploymentAddresses(taskArgs.targetNetwork))
    const dstAddr = getDeploymentAddresses(taskArgs.targetNetwork)["OmniCounter"]
    // get local contract instance
    const omniCounter = await ethers.getContract("OmniCounter")
    console.log(`[source] omniCounter.address: ${omniCounter.address}`)

    // set the config for this UA to use the specified Oracle
    let tx = await (await omniCounter.incrementCounter(
        dstChainId,
        dstAddr,
        {value: ethers.utils.parseEther('0.01')} // estimate/guess
    )).wait()
    console.log(`✅ Message Sent [${hre.network.name}] incrementCounter on destination OmniCounter @ [${dstChainId}] [${dstAddr}]`)
    console.log(`tx: ${tx.transactionHash}`)

    console.log(``)
    console.log(`Note: to poll/wait for the message to arrive on the destination use the command:`)
    console.log('')
    console.log(`    $ npx hardhat --network ${taskArgs.targetNetwork} omniCounterPoll`)
}