const { expect } = require("chai");
const BN = require("bn.js");

chai.use(require("chai-bn")(BN));

describe(Unipay,function () {
    before(async function (){
        Unipay = await ethers.getContractFactory("UniPay");
        unipay = await Unipay.deploy();
        await unipay.deployed();
    });
    beforeEach(async function() {
      await unipay.setAddress("0x84F0eefe32AaCc1a250AD56699E51A947bC351e0");
    });
})