FROM hyperledger/fabric-tools:1.4.3
LABEL maintainer="nn@mikh.pro"

ENV GOPATH=/opt/gopath

RUN go get github.com/hyperledger/fabric-chaincode-go/shim && \
	go get github.com/hyperledger/fabric-protos-go/peer
