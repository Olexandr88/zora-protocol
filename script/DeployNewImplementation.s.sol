// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {ZoraDeployerBase} from "./ZoraDeployerBase.sol";
import {ChainConfig, Deployment} from "../src/deployment/DeploymentConfig.sol";

import {ZoraCreator1155FactoryImpl} from "../src/factory/ZoraCreator1155FactoryImpl.sol";
import {Zora1155Factory} from "../src/proxies/Zora1155Factory.sol";
import {ZoraCreator1155Impl} from "../src/nft/ZoraCreator1155Impl.sol";
import {ICreatorRoyaltiesControl} from "../src/interfaces/ICreatorRoyaltiesControl.sol";
import {IZoraCreator1155Factory} from "../src/interfaces/IZoraCreator1155Factory.sol";
import {IZoraCreator1155} from "../src/interfaces/IZoraCreator1155.sol";
import {IMinter1155} from "../src/interfaces/IMinter1155.sol";
import {ZoraCreatorFixedPriceSaleStrategy} from "../src/minters/fixed-price/ZoraCreatorFixedPriceSaleStrategy.sol";
import {ZoraCreatorMerkleMinterStrategy} from "../src/minters/merkle/ZoraCreatorMerkleMinterStrategy.sol";
import {ZoraCreatorRedeemMinterFactory} from "../src/minters/redeem/ZoraCreatorRedeemMinterFactory.sol";
import {Create2Deployment, ZoraDeployerUtils} from "../src/deployment/ZoraDeployerUtils.sol";
import {DeterministicDeployerScript} from "../src/deployment/DeterministicDeployerScript.sol";

/// @dev Deploys implementation contracts for 1155 contracts.
/// @notice Run after deploying the minters
/// @notice This
contract DeployNewImplementations is ZoraDeployerBase, DeterministicDeployerScript {
    function run() public returns (string memory) {
        Deployment memory deployment = getDeployment();
        ChainConfig memory chainConfig = getChainConfig();

        deployment.upgradeGate = determinsticUpgradeGateAddress();

        vm.startBroadcast();

        (address factoryImplDeployment, address contract1155ImplDeployment) = ZoraDeployerUtils.deployNew1155AndFactoryImpl(
            address(deployment.upgradeGate),
            chainConfig.mintFeeRecipient,
            chainConfig.protocolRewards,
            IMinter1155(deployment.merkleMintSaleStrategy),
            IMinter1155(deployment.redeemMinterFactory),
            IMinter1155(deployment.fixedPriceSaleStrategy)
        );

        address factoryProxyAddress = readDeterministicParams("factoryProxy").deterministicProxyAddress;

        deployment.preminterImpl = ZoraDeployerUtils.deployNewPreminterImplementationDeterminstic(factoryProxyAddress);

        deployment.factoryImpl = factoryImplDeployment;
        deployment.contract1155Impl = contract1155ImplDeployment;

        return getDeploymentJSON(deployment);
    }
}
