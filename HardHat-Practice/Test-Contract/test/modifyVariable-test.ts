import {expect, assert } from "chai";
import { ethers } from "hardhat";

describe("ModifyVariable", function () {
    it("should change x to 1337", async function() {
      const ModifyVariable = await ethers.getContractFactory("ModifyVariable");  
      
      const contract = await ModifyVariable.deploy(7);
      await contract.deployed();

      await contract.modifyToLeet();
      const newX = await contract.x();

      //expect(newX).to.equal(1337);

      assert.equal(newX.toNumber(), 1337, "x was not modified to 1337");



    } )
});