-- GENERAL

CREATE TABLE transactions
(
    signature VARCHAR(88),
    transaction_index UInt32,
    slot UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature);

CREATE TABLE blocks
(
    slot UInt64,
    height UInt64,
    time UInt64,
    hash VARCHAR(88),
)
ENGINE = MergeTree
PRIMARY KEY (slot);

-- RAYDIUM EVENTS

CREATE TABLE raydium_swap_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm LowCardinality(VARCHAR(44)) CODEC(LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint_out LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_initialize_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm LowCardinality(VARCHAR(44)) CODEC(LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    pc_init_amount UInt64,
    coin_init_amount UInt64,
    lp_init_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_deposit_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm LowCardinality(VARCHAR(44)) CODEC(LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_withdraw_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm LowCardinality(VARCHAR(44)) CODEC(LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    decimals UInt32,
    mint_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    account_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    account_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    multisig LowCardinality(VARCHAR(44)) CODEC(LZ4),
    -- signers Array(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    m UInt32,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
    authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_approve_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    delegate LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    authority_type LowCardinality(VARCHAR(14)) CODEC(LZ4),
    new_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    destination_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_burn_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    signature LowCardinality(VARCHAR(88)) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    account_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    account_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);
