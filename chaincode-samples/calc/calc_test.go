package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"strconv"
	"testing"
)

func initChaincode(t *testing.T) *shim.MockStub {
	stub := shim.NewMockStub("CalcTestStub", new(CalcToken))
	response := stub.MockInit("mockTxId", nil)
	status := response.GetStatus()
	t.Logf("Received status := %d", status)
	if status != shim.OK {
		t.FailNow()
	}
	return stub
}

func TestAdd(t *testing.T) {
	stub := initChaincode(t)
	response := invoke(stub, "add", "10")
	result, _ := strconv.ParseInt(string(response.Payload), 10, 64)
	t.Logf("Add received result: %d", result)
	if result != 110 {
		t.Fail()
	}
}

func TestSubstruct(t *testing.T) {
	stub := initChaincode(t)
	response := invoke(stub, "substract", "20")
	result, _ := strconv.ParseInt(string(response.Payload), 10, 64)
	t.Logf("Substract received result: %d", result)
	if result != 80 {
		t.Fail()
	}
}

func invoke(stub *shim.MockStub, funcName string, args ...string) peer.Response {
	ccArgs := setupArgsArray(funcName, args...)
	return stub.MockInvoke("TxSub", ccArgs)
}

func setupArgsArray(funcName string, args ...string) [][]byte {
	ccArgs := make([][]byte, 1+len(args))
	ccArgs[0] = []byte(funcName)
	for i, arg := range args {
		ccArgs[i+1] = []byte(arg)
	}
	return ccArgs
}
