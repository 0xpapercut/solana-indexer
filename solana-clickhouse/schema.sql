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
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in VARCHAR(44) CODEC(LZ4),
    mint_out VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_initialize_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_init_amount UInt64,
    coin_init_amount UInt64,
    lp_init_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
    lp_mint VARCHAR(44),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_deposit_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
    lp_mint VARCHAR(44),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE raydium_withdraw_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    amm VARCHAR(44) CODEC(LZ4),
    user VARCHAR(44) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint VARCHAR(44),
    coin_mint VARCHAR(44),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    mint VARCHAR(44) CODEC(LZ4),
    decimals UInt32,
    mint_authority VARCHAR(44) CODEC(LZ4),
    freeze_authority VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    account_address VARCHAR(44) CODEC(LZ4),
    account_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    multisig VARCHAR(44) CODEC(LZ4),
    signers Array(VARCHAR(44)) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    destination_address VARCHAR(44) CODEC(LZ4),
    destination_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    amount UInt64,
    authority VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_approve_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    delegate VARCHAR(44) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    mint VARCHAR(44) CODEC(LZ4),
    authority_type VARCHAR(14) CODEC(LZ4),
    new_authority VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    destination_address VARCHAR(44) CODEC(LZ4),
    destination_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    mint_authority VARCHAR(44) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_burn_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    authority VARCHAR(44) CODEC(LZ4),
    amount UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    destination VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    freeze_authority VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    source_address VARCHAR(44) CODEC(LZ4),
    source_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    freeze_authority VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    signature VARCHAR(88) CODEC(LZ4),
    instruction_index UInt32,
    transaction_index UInt32,
    slot UInt64,
    account_address VARCHAR(44) CODEC(LZ4),
    account_owner VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index);
