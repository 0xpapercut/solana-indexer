CREATE TABLE transactions
(
    signature VARCHAR(88)
)
ENGINE = MergeTree
PRIMARY KEY (signature);

CREATE TABLE addresses
(
    address VARCHAR(44)
)
ENGINE = MergeTree
PRIMARY KEY (address);

CREATE TABLE raydium_swap_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in VARCHAR(44) CODEC(LZ4),
    mint_out VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (amm) REFERENCES addresses(address),
    FOREIGN KEY (user) REFERENCES addresses(address),
    FOREIGN KEY (mint_in) REFERENCES addresses(address),
    FOREIGN KEY (mint_out) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE raydium_initialize_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
    lp_mint VARCHAR(44),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (amm) REFERENCES addresses(address),
    FOREIGN KEY (user) REFERENCES addresses(address),
    FOREIGN KEY (pc_mint) REFERENCES addresses(address),
    FOREIGN KEY (coin_mint) REFERENCES addresses(address),
    FOREIGN KEY (lp_mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE raydium_deposit_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
    lp_mint VARCHAR(44),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (amm) REFERENCES addresses(address),
    FOREIGN KEY (user) REFERENCES addresses(address),
    FOREIGN KEY (pc_mint) REFERENCES addresses(address),
    FOREIGN KEY (coin_mint) REFERENCES addresses(address),
    FOREIGN KEY (lp_mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE raydium_withdraw_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
    lp_mint VARCHAR(44),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (amm) REFERENCES addresses(address),
    FOREIGN KEY (user) REFERENCES addresses(address),
    FOREIGN KEY (pc_mint) REFERENCES addresses(address),
    FOREIGN KEY (coin_mint) REFERENCES addresses(address),
    FOREIGN KEY (lp_mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);
