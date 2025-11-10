import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { network } from "hardhat";
import { Address } from "web3";

describe("Proxy", async function () {
  const { viem } = await network.connect();
  const publicClient = await viem.getPublicClient();

  //eth_getStorageAt
async function lookupUint(contractAddress: Address, slot: string): Promise<bigint> {
  const storageValue = await publicClient.getStorageAt({
    address: contractAddress,
    slot
  });

  if (!storageValue) {
    throw new Error(`No storage value found at slot ${slot}`);
  }

  return BigInt(storageValue);
}



  it("Should work with upgrades (with same interafce)", async function () {
     const implementation1 = await viem.deployContract("Logic1");
    const implementation2 = await viem.deployContract("Logic2");
    const proxy = await viem.deployContract("Proxy", [implementation1.address]);

    await proxy.write.changeX([42n]);
    assert.equal(await implementation1.read.x(), 42n);

    await proxy.write.changeImplementation([implementation2.address]);
    await proxy.write.changeX([100n]);
    assert.equal(await implementation2.read.x(), 200n);
  });
  

  it("Should work with upgrades (with different interface)", async function () {
    const implementation1 = await viem.deployContract("Logic1");
    const implementation2 = await viem.deployContract("Logic2");
    const proxy = await viem.deployContract("Proxy", [implementation1.address]);

    await proxy.write.changeX([7n]);
    assert.equal(await implementation1.read.x(), 7n);

    await proxy.write.changeImplementation([implementation2.address]);
    
    // upgrade to Logic2
    const proxyAsLogic2 = await viem.getContractAt("Logic2", proxy.address);

    await proxyAsLogic2.write.tripleX([10n]);
    assert.equal(await lookupUint(proxy.address, "0x0"), 30n);

    
  });

});
