ENDPOINT ?= mainnet.sol.streamingfast.io:443
UNDO_BUFFER_SIZE ?= 300

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
sink:
	substreams-sink-sql run $(DSN) $(MANIFEST) $(START):$(STOP) --undo-buffer-size $(UNDO_BUFFER_SIZE) --on-module-hash-mistmatch=warn

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --exclude-paths="sf/substreams,google"

.PHONY: clean_db
clean_db:
	@db_name=$$(echo $(DSN) | sed -n 's/.*\/\([^?]*\).*/\1/p'); \
	read -p "WARNING: Are you sure you want to clean $$db_name? [y/N] " confirm && if [ "$$confirm" = "y" ]; then \
		clickhouse-client --query "DROP DATABASE IF EXISTS $$db_name"; \
		clickhouse-client --query "CREATE DATABASE $$db_name"; \
	fi
