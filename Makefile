ENDPOINT ?= mainnet.sol.streamingfast.io:443
UNDO_BUFFER_SIZE ?= 60

SCHEMA_FILE = "./schema.sql"
MANIFEST = "./substreams.yaml"

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: stream
stream: build
	if [ -n "$(STOP)" ]; then \
		substreams run -e $(ENDPOINT) substreams.yaml block_database_changes -s $(START) -t $(STOP); \
	elif [ -n "$(START)" ]; then \
		substreams run -e $(ENDPOINT) substreams.yaml block_database_changes -s $(START); \
	else \
	substreams run -e $(ENDPOINT) substreams.yaml block_database_changes; \
	fi

.PHONY: setup_db
setup_db: build
	substreams-sink-sql setup $(DSN) $(MANIFEST)

.PHONY: sink
sink: build
	substreams-sink-sql run $(DSN) $(MANIFEST) $(START): --undo-buffer-size $(UNDO_BUFFER_SIZE) --on-module-hash-mistmatch=warn

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --exclude-paths="sf/substreams,google"
