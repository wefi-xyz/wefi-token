
module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    await deploy("WidgetOFTBridge", {
        from: deployer,
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["WidgetOFTBridge"]
