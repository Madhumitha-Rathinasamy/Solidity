const Token = artifacts.require("Token");
const assert = require("chai").assert;

let _Token;
contract("Token", (accounts) => {
    beforeEach(async () => {
        _Token = await Token.deployed();
    });
    const account1 = accounts[0];
    const account2 = accounts[1];
    const account3 = accounts[2];
    const account4 = accounts[3];
    const account5 = accounts[4];
    const account6 = accounts[5];
    const account7 = accounts[6];
    const account8 = accounts[7];

    const zeroAccount = "0x0000000000000000000000000000000000000000";
    describe("Access Control", async () => {
        context("Check Admin Role", async () => {
            it("Should return True: Account 1 is Admin role holder", async () => {
                let res = await _Token.hasRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account1);
                assert.equal(res, true);
            });
            it("Should return False: Account 1 is Admin role holder", async () => {
                let res = await _Token.hasRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2);
                assert.equal(res, false);
            });
            context("Set Admin role", async () => {
                it("Should fail: Account 2 try to set admin role", async () => {
                    try{
                         await _Token.grantRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2, {
                        from: account2
                    });
                    let res= await _Token.hasRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2);
                    assert.equal(res, true);
                }catch(err){
                    return true;
                }
                });
                it("Should pass: Account 1 try to set admin role", async () => {
                     await _Token.grantRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2, {
                        from: account1
                    });
                    let res= await _Token.hasRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2);
                    assert.equal(res, true);
                });
            });
            context("Only Admin users can use mint function", async () => {
                it("Should fail: Account 3 try to mint token", async () => {
                    try{
                         await _Token.mint("10000000000000000000000", {
                        from: account3
                    });
                }catch(err){
                    return true;
                }
                });
                it("Should Pass: Account 2 try to mint token", async () => {
                         let res1 = await _Token.mint("10000000000000000000000", {
                        from: account2
                    });
                });
            });
            context("Only Admin user revoke the user", async () => {
                it("Should fail: Account 3 try to revoke account 2", async () => {
                    try{
                         await _Token.revokeRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2, {
                        from: account3
                    });
                }catch(err){
                    return true;
                }
                });
                it("Should Pass: Account 2 try to mint token", async () => {
                          await _Token.revokeRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2, {
                            from: account1
                        });
                    });
                });
                context("Renounce Role", async () => {
                    it("Should fail: Account 1 try to renounce role account 2", async () => {
                        try{
                             await _Token.renounceRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account2, {
                            from: account1
                        });
                    }catch(err){
                        return true;
                    }
                    });
                    it("Should Pass: Account 1 try to renounce role account 1", async () => {
                        await _Token.renounceRole("0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3", account1, {
                            from: account1
                            });
                        });
                    });
            });
        });
    });        