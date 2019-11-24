# HLF Dev

The project implements an GoLang development environment to run Hyperledger Fabric (v1.4) chaincode

## Features

* quick launch of blockchain network and chaincode
* adjusting the chaincode does not require restarting the network (in most cases)
* parallel launch of several interacting chaincodes
* display chaincode events
* use of msp from Fabric CA (you can debug the attributes of the contract)
* Explorer included

## Preface

This project was inspired by the wonderful **Mastering Hyperledger Chaincode Development course using GoLang** ([udemy](https://www.udemy.com/course/golang-chaincode-development/))

Some useful links:

[Udemy Course](https://www.udemy.com/course/golang-chaincode-development/)

[Sourcecode for Course](https://github.com/acloudfan/HLFGO-Token)

[Other Courses](http://www.bcmentors.com/courses/)

[Fabric Samples Sourcecode](https://github.com/hyperledger/fabric-samples)

[Hyperledger Docker Images](https://hub.docker.com/search?q=hyperledger&type=image)



## Scripts Overview

The following scripts will be used in sections below:

`up.sh` - run development environment. It's a simple shell around *docker-compose*

`run-cc.sh` - run one or more chaincodes in the development environment

`ii.sh` - install and instantiate chaincode

`query.sh` - *query* request to the chaincode

`invoke.sh` - *invoke* request to the chaincode



## Usage

System requirements:

* Ubuntu (tested on version Ubuntu Desktop 19.04 x64)
* go 1.11+ and following packages: `github.com/golang/protobuf/protoc-gen-go`, `github.com/hyperledger/fabric-chaincode-go/shim`,  `github.com/hyperledger/fabric-protos-go/peer`
* docker 18.09+
* docker-compose 1.22+
* parallel (if you need to run multiple chain codes in parallel) https://www.gnu.org/software/parallel/

### Run Simple Chaincode

To use *HLF Dev* to run and debug your chain codes, you can get this project as a git module in your repository

Create a directory and a chaincode file
```bash
cd $GOPATH/src
mkdir tokenv5
cd tokenv5
```
Adding git module

```bash
git init
git submodule add https://github.com/nmix/hlf-dev.git dev-mode
```

Using the sample of chaincode from the dev-mode
```bash
cp dev-mode/chaincode-samples/tokenv5.go .
```

Startup environment and chaincode

```bash
# Terminal 1
cd dev-mode
# --- run env
./up.sh
# --- compiling and running chaincode
./run-cc.sh tokenv5
# ...
# ... INFO 002 Chaincode (build level: ) starting up ...

# Terminal 2
cd dev-mode
# --- installation and instantiation of codecode
./ii.sh -ntokenv5
# ...
# ... INFO 04d Installed remotely: response:<status:200 payload:"OK" >

# Terminal 1
# debug output
# Init executed

# Terminal 2
# request for a code value
./query.sh -ntokenv5 get
# MyToken=2000

./invoke.sh -ntokenv5 set
# ... Chaincode invoke successful. result: status:200 payload:"true"

./query.sh -ntokenv5 get
# MyToken=2010

# stop the environment
./down.sh
```

## Multiple chaincodes

Running multiple chaincodes in a single execution context may be required to debug the interaction of the developed chaincode with other chaincodes

In example below we will call *tokenv5.go* from *caller.go*.

```bash
# --- create a directory for the new chaincode
cd $GOPATH/src
mkdir caller
cd caller

# --- initialize the repository and pull the dev-mode module
git init
git submodule add https://github.com/nmix/hlf-dev.git  dev-mode

# --- copy the example chaincode to the current folder
cp dev-mode/chaincode-samples/caller.go .
```

There should be the following directory structure:

```bash
# $GOPATH/src
.
├── caller
│   ├── caller.go
│   └── dev-mode
├── tokenv5
│   └── tokenv5.go
```

Run project

```bash
# Terminal 1
# $GOPATH/src/caller
cd dev-mode
./up.sh
./run-cc.sh caller tokenv5

# Terminal 2
./ii.sh -ntokenv5
./ii.sh -ncaller
./query.sh -ncaller getOnCaller
# MyToken=2000

# Terminal 1
# Receieved GET response from 'token' : status:200 payload:"MyToken=2000"

# Terminal 2
./invoke.sh -ncaller setOnCaller
# Chaincode invoke successful. result: status:200 payload:"true"

./query.sh -ncaller getOnCaller
# MyToken=2010

# stop environment
./down.sh
```

## Chaincode Event Listening

Listening for events from chaincode is done using a script *listener.sh*

Listening tokenv5 smart contract events (see "Run Simple Chaincode" section)

```bash
# Terminal 1
./up.sh
./run-cc.sh tokenv5

# Terminal 2
./ii.sh -ntokenv5

# Terminal 3
./listener.sh tokenv5 TokenValueChanged

# Terminal 2
./invoke.sh -ntokenv5 set

# Terminal 3
# listener    | ✅  event= TokenValueChanged
# listener    |  block# 2
# listener    |  status= VALID
# listener    |  payload= 2010

# stop listener
^C

# --- stop environment
./down.sh
```

> @todo
> When you run several chain codes for some reason, only the events of the first chain code in the list are processed.

## Range Queries

Example of use Range Queries


```bash

# --- init project

cd $GOPATH/src
mkdir range
cd range

git init
git submodule add https://github.com/nmix/hlf-dev.git dev-mode

cp dev-mode/chaincode-samples/range.go .

# --- run chaincode

# Terminal 1
cd dev-mode
# --- run env
./up.sh
# --- compiling and running chaincode
./run-cc.sh range
# ...
# ... INFO 002 Chaincode (build level: ) starting up ...

# Terminal 2
cd dev-mode
# --- installation and instantiation of codecode
./ii.sh -nrange init 1 50
# ...
# ... INFO 04d Installed remotely: response:<status:200 payload:"OK" >

# Terminal 1
# debug output
# Init executed in qry   startIndex=1   recordCount=50
# Initialized Chaincode with 50 Tokens

# Terminal 2
# requests for a code value

./query.sh -nrange GetTokenByRange key10 key12
# { "count":2,"queryResult":[{"key":"key10","token":{"symbol":"TOK10","totalSupply":1000}},
# {"key":"key11","token":{"symbol":"TOK11","totalSupply":1000}}]}

./query.sh -nrange GetTokenByRange key1 key2
# { "count":11,"queryResult":[{"key":"key1","token":{"symbol":"TOK1","totalSupply":1000}},
# {"key":"key10","token":{"symbol":"TOK10","totalSupply":1000}},
# {"key":"key11","token":{"symbol":"TOK11","totalSupply":1000}},
# {"key":"key12","token":{"symbol":"TOK12","totalSupply":1000}},
# {"key":"key13","token":{"symbol":"TOK13","totalSupply":1000}},
# {"key":"key14","token":{"symbol":"TOK14","totalSupply":1000}},
# {"key":"key15","token":{"symbol":"TOK15","totalSupply":1000}},
# {"key":"key16","token":{"symbol":"TOK16","totalSupply":1000}},
# {"key":"key17","token":{"symbol":"TOK17","totalSupply":1000}},
# {"key":"key18","token":{"symbol":"TOK18","totalSupply":1000}},
# {"key":"key19","token":{"symbol":"TOK19","totalSupply":1000}}]}

# stop the environment
./down.sh
```

## Certificate Authority

*dev-mode* certificates are generated using *Fabric-CA*, and not using the *cryptogen* utility. Therefore, it is possible to debug program access control in the code. Chaincode requests using various user certificates are made by the `-uUSERNAME` option, where *USERNAME* is the name of the directory in *config/users*.

Create a directory and a chaincode file

```bash
cd $GOPATH/src
mkdir cid
cd cid
```
Add git module *dev-mode*
```bash
git init
git submodule add https://github.com/nmix/hlf-dev.git dev-mode
```

We use the sample from the dev-mode project as a chaincode:

```bash
cp dev-mode/chaincode-samples/cid.go .
```

Run the environment and chaincode

```bash
# Terminal 1
cd dev-mode
./up.sh
./run-cc.sh cid

# Terminal 2
cd dev-mode
# --- installation and instantiation of chaincode
./ii.sh -ncid

# user credential display request
# the request is made as root (see config/users/root/msp)
./query.sh -ncid PrintCallerIDs
# ok

# Terminal 1
#
# GerID() =              eDUwOTo6Q049cm9vdCxPVT11c2VyK09VPVNhbXBsZU9yZyxPPUh5cGVybGVkZ2VyLFNUPU5vcnRoIENhcm9saW5hLEM9VVM6OkNOPWNhLnNhbXBsZS5jb20sTz1TYW1wbGVDQSxTVD1LcmFzbm9kYXIsQz1SVQ==
# GetMSPID() =           SampleOrg
# hf.Affiliation =       SampleOrg
# hf.EnrollmentID =      root		<--------------------------
# hf.Type =              user		<--------------------------
# app.accounting.role =  
# department =           

# Certificate data
# Version:               3
# Issuer:                CN=ca.sample.com,O=SampleCA,ST=Krasnodar,C=RU
# Subject:               CN=root,OU=user+OU=SampleOrg,O=Hyperledger,ST=North Carolina,C=US
# NotBefore:             2019-11-01 08:45:00 +0000 UTC
# NotAfter:              2020-10-31 08:50:00 +0000 UTC

# Terminal 2
# same request as user mary (config/users/mary/msp)
./query.sh -ncid -umary PrintCallerIDs

# Terminal 1
#
# ...
# hf.EnrollmentID =      mary		<--------------------------
# hf.Type =              user		<--------------------------
# app.accounting.role =  manager	<--------------------------
# department =           accounting	<--------------------------
# ...

# Terminal 2
./query.sh -ncid -umary AsssertOnCallersDepartment
# Access Granted to mary from accounting

./query.sh -ncid -ujohn AsssertOnCallersDepartment
# Access Granted to john from accounting

./query.sh -ncid -uvitalik AsssertOnCallersDepartment
# Error: endorsement failure during query. response: status:500 message:"Access Denied to vitalik from logistics !!!"


# stop environment
./down.sh
```

## Explorer

The launch of *explorer* must be carried out after starting the network nodes, i.e. after the command `./up.sh`

```bash
./up.sh
./explorer.sh
```

Go to the address *http://localhost:8080*, username *root*, password *pw*

## Useful features

### Arguments with spaces

Perhaps (and most likely it will) it will be necessary to use arguments containing spaces when invoking the chaincode. In this case, you must wrap the argument in double quotation marks

```bash
./invoke.sh -nhistory TransferOwnership 100 "J Smith" "H Koolaid" 2019-01-01
./invoke.sh -nhistory TransferOwnership 100 "H Koolaid" "M Rainbow" 2019-02-01
```

A similar rule works with scripts *ii.sh* and *query.sh*

### JSON as an argument

For complex queries, you may need to pass JSON as an argument. In order to do this, it is necessary to wrap JSON in single quotes, and each JSON element in double:

```bash
./query.sh -nrichq ExecuteRichQuery '{\"selector\": {\"txnDate\": \"2009-01-12T00:00:00Z\"}}'
```

## Project configuration

### Artifact generation

The project starts with a predefined configuration (see the */config* directory). If necessary, you can change the settings with the obligatory re-creation of network artifacts.


```bash
# Genesis block

docker run --rm -it \
  -v $(pwd)/config/:/etc/hyperledger/fabric \
  -v $(pwd):/artefacts \
  zoidenberg/fabric-tools:1.4.3 \
  configtxgen \
    -profile SampleDevModeSolo \
    -outputBlock /artefacts/orderer.block \
    -channelID ordererchannel

# Channel configuration

docker run --rm -it \
  -v $(pwd)/config/:/etc/hyperledger/fabric \
  -v $(pwd):/artefacts \
  zoidenberg/fabric-tools:1.4.3 \
  configtxgen \
    -profile SampleSingleMSPChannel \
    -outputCreateChannelTx /artefacts/myc.tx \
    -channelID myc
```

### MSP Generation

*Dev-mode* certificates are generated using *Fabric-CA*, and not using the *cryptogen* utility. The following are the commands used to create msp for nodes and users

```bash
# --- launch fabric-ca
docker run --rm -d \
  --name sampleca \
  -v $(pwd)/config:/etc/hyperledger \
  -e FABRIC_CA_HOME=/etc/hyperledger/caserver \
  -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/caclient \
  hyperledger/fabric-ca:1.4.3

# --- get msp "super" admin
docker exec -it sampleca fabric-ca-client enroll

# --- add a structural unit (if not previously created)
docker exec -it sampleca fabric-ca-client affiliation add SampleOrg

# --- create msp admin
docker exec -it sampleca fabric-ca-client register \
  --id.type user \
  --id.name root \
  --id.secret pw \
  --id.affiliation SampleOrg \
  --id.attrs '"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true","hf.Registrar.Attributes=*"'

docker exec -it sampleca fabric-ca-client enroll \
  -u http://root:pw@localhost:7054 \
  -M /etc/hyperledger/users/root/msp

# --- create msp user mary
docker exec -it sampleca fabric-ca-client register \
  --id.type user \
  --id.name mary \
  --id.secret pw \
  --id.affiliation SampleOrg \
  --id.attrs '"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.accounting.role=manager:ecert","department=accounting:ecert"'

docker exec -it sampleca fabric-ca-client enroll \
  -u http://mary:pw@localhost:7054 \
  -M /etc/hyperledger/users/mary/msp

# --- creating msp by john
docker exec -it sampleca fabric-ca-client register \
  --id.type user \
  --id.name john \
  --id.secret pw \
  --id.affiliation SampleOrg \
  --id.attrs '"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.accounting.role=accountant:ecert","department=accounting:ecert"'

docker exec -it sampleca fabric-ca-client enroll \
  -u http://john:pw@localhost:7054 \
  -M /etc/hyperledger/users/john/msp

# --- creating msp by vitalik
docker exec -it sampleca fabric-ca-client register \
  --id.type user \
  --id.name vitalik \
  --id.secret pw \
  --id.affiliation SampleOrg \
  --id.attrs '"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.logistics.role=specialist:ecert","department=logistics:ecert"'

docker exec -it sampleca fabric-ca-client enroll \
  -u http://vitalik:pw@localhost:7054 \
  -M /etc/hyperledger/users/vitalik/msp

# --- creating msp orderer node
docker exec -it sampleca fabric-ca-client register \
  --id.type orderer \
  --id.name orderer \
  --id.affiliation SampleOrg \
  --id.secret pw

docker exec -it sampleca fabric-ca-client enroll \
  -u http://orderer:pw@localhost:7054 \
  -M /etc/hyperledger/orderers/orderer/msp

# --- creating msp peer node
docker exec -it sampleca fabric-ca-client register \
  --id.type peer \
  --id.name peer \
  --id.affiliation SampleOrg \
  --id.secret pw

docker exec -it sampleca fabric-ca-client enroll \
  -u http://peer:pw@localhost:7054 \
  -M /etc/hyperledger/peers/peer/msp
```
