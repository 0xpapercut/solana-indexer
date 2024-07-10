-- GENERAL

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

-- RAYDIUM EVENTS

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

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    mint VARCHAR(44) CODEC(LZ4),
    decimals UInt32,
    mint_authority VARCHAR(44) CODEC(LZ4),
    freeze_authority Nullable(VARCHAR(44)) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (mint) REFERENCES addresses(address),
    FOREIGN KEY (mint_authority) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_initialize_multisig_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    -- TODO
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_transfer_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    destination_address VARCHAR(44) CODEC(LZ4),
    destination_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    amount UInt64,
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (destination_address) REFERENCES addresses(address),
    FOREIGN KEY (destination_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_approve_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    source_mint VARCHAR(44) CODEC(LZ4),
    delegate VARCHAR(44) CODEC(LZ4),
    amount UInt64,
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (source_mint) REFERENCES addresses(address),
    FOREIGN KEY (delegate) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_revoke_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    source_mint VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (source_mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_set_authority_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    mint VARCHAR(44) CODEC(LZ4),
    authority_type VARCHAR(14) CODEC(LZ4),
    new_authority Nullable(VARCHAR(44)) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (mint) REFERENCES addresses(address),
    FOREIGN KEY (new_authority) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_mint_to_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    destination_address VARCHAR(44) CODEC(LZ4),
    destination_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    amount UInt64,
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (destination_address) REFERENCES addresses(address),
    FOREIGN KEY (destination_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_burn_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_close_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    destination VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_freeze_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_thaw_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);

CREATE TABLE spl_token_initialize_immutable_owner_event
(
    signature VARCHAR(88) CODEC(LZ4),
    event_id UInt64,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    FOREIGN KEY (signature) REFERENCES transactions(signature),
    FOREIGN KEY (source_address) REFERENCES addresses(address),
    FOREIGN KEY (source_owner) REFERENCES addresses(address),
    FOREIGN KEY (mint) REFERENCES addresses(address),
)
ENGINE = MergeTree
PRIMARY KEY (signature, event_id);
