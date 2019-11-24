/**
 * https://fabric-sdk-node.github.io/release-1.3/tutorial-network-config.html
 * 
 * https://fabric-sdk-node.github.io/tutorial-network-config.html
 * 
 * node event.js ChaincodeName EventName
 *
 * ex:
 * node events.js token InvokeTokenEvent
 */

'use strict';

var Client = require('fabric-client');
const fs = require('fs');
const yaml = require('node-yaml')

const listenerType="chaincode"
const channelId="myc"
const cryptoType="cryptogen"

/**
 * Arguments
 */
var ccName=process.argv[2]
var ccEvent=process.argv[3]

console.log("Launching Listener: "," type=",listenerType," cc Name=",ccName," event Name=",ccEvent)

Client.setConfigSetting('network','/etc/hyperledger/profiles/dev.json');
let client = Client.loadFromConfig(Client.getConfigSetting('network'));


async function launch(){
    await client.initCredentialStores();
    if(listenerType=="block"){
        blockListener()
    } else if(listenerType=="chaincode") {
        chaincodeEventListener()
    }
}

launch()

function    blockListener() {
    var channel = client.getChannel(channelId)
    var channel_event_hub = channel.newChannelEventHub('peer0.org1.example.com');
    var block_reg = channel_event_hub.registerBlockEvent((block) => {
        console.log('Successfully received the block number=',block.header.number);
    }, (error)=> {
        console.log('Failed to receive the block event ::'+error);
        console.log("Error:", error)
    }
    );
    channel_event_hub.connect(true); 
}

function chaincodeEventListener() {
    var channel = client.getChannel(channelId)
    var channel_event_hub = channel.newChannelEventHub('peer0.org1.example.com');
    var cc_reg = channel_event_hub.registerChaincodeEvent(ccName,ccEvent,(event, block_num, txnid, status)=>{
        var payload = event.payload
        let INFO_SYMBOL='\u2705'
        console.log(INFO_SYMBOL, ' event=',event.event_name,'\n block#',block_num,"\n status=",status,"\n payload=",payload.toString('utf8') )
    }, (error)=>{
        console.log("Error:", error)
    })
    channel_event_hub.connect(true);
}
