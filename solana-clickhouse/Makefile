START ?= 275355786
ENDPOINT ?= mainnet.sol.streamingfast.io:443

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: stream
stream: build
	if [ -n "$(STOP)" ]; then \
		substreams run -e $(ENDPOINT) substreams.yaml db_out -s $(START) -t $(STOP); \
	else \
		substreams run -e $(ENDPOINT) substreams.yaml db_out -s $(START); \
	fi

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --exclude-paths="sf/substreams,google"
