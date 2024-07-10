ENDPOINT ?= mainnet.sol.streamingfast.io:443

SCHEMA_FILE = "./schema.sql"
MANIFEST = "./substreams.yaml"

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

.PHONY: setup_db
setup_db:
	substreams-sink-sql setup $(DSN) $(MANIFEST)

.PHONY: clean_db
clean_db:
	clickhouse-client --query "DROP DATABASE IF EXISTS solana"
	clickhouse-client --query "CREATE DATABASE solana"
	# clickhouse-client --query "$(cat $(SCHEMA_FILE))"

.PHONY: sink
sink:
	substreams-sink-sql run $(DSN) $(MANIFEST) $(START): --undo-buffer-size $(UNDO_BUFFER_SIZE)

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --exclude-paths="sf/substreams,google"
