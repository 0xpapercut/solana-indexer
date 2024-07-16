# solana-clickhouse
Sink SPL Token and Raydium events into a Clickhouse database.

## Usage
1. [Download `substream-sink-sql` v4.2.0](https://github.com/streamingfast/substreams-sink-sql/releases/tag/v4.2.0).
2. Setup `DSN` and `STREAMINGFAST_KEY` environment variables.
3. Run `. ../token.sh` to setup the `SUBSTREAMS_API_TOKEN` environment variable.
4. Run the sink with `make sink`

Please note that setting up `DSN` involves creating a clickhouse database and making it available by some combination of connection and credentials, both of which are described by the `DSN` variable.
