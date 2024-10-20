-- FUNCTIONS

CREATE FUNCTION getPairHash AS (mint0, mint1) -> cityHash64(if(mint_in < mint_out, concat(mint_in, mint_out), concat(mint_out, mint_in)));

-- BLOCKS

CREATE TABLE blocks
(
    slot UInt64,
    parent_slot UInt64,
    block_height UInt64,
    blockhash String,
    previous_blockhash String,
    block_time DateTime,
    insertion_time DateTime MATERIALIZED now(),
)
ENGINE = MergeTree
PRIMARY KEY slot
ORDER BY slot;

-- TRANSACTIONS

CREATE TABLE transactions
(
    slot UInt64,
    transaction_index UInt64,
    signature String,
    number_of_signers UInt8,
    signer0 String,
    signer1 String DEFAULT '',
    signer2 String DEFAULT '',
    signer3 String DEFAULT '',
    signer4 String DEFAULT '',
    signer5 String DEFAULT '',
    signer6 String DEFAULT '',
    signer7 String DEFAULT '',
    -- signers Array(String),
    -- PROJECTION projection_signature (SELECT * ORDER BY signature) -- RECOMMENDED
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index)
ORDER BY (slot, transaction_index);

-- RAYDIUM AMM EVENTS

CREATE TABLE raydium_amm_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in LowCardinality(String) CODEC(LZ4),
    mint_out LowCardinality(String) CODEC(LZ4),
    direction LowCardinality(String) CODEC(LZ4),
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_pair_hash (SELECT * ORDER BY getPairHash(mint_in, mint_out), slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_mint_in (SELECT * ORDER BY mint_in, slot, transaction_index, instruction_index),
    -- PROJECTION projection_mint_out (SELECT * ORDER BY mint_out, slot, transaction_index, instruction_index),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_initialize_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    pc_init_amount UInt64,
    coin_init_amount UInt64,
    lp_init_amount UInt64,
    pc_mint LowCardinality(String) CODEC(LZ4),
    coin_mint LowCardinality(String) CODEC(LZ4),
    lp_mint LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_pair_hash (SELECT * ORDER BY getPairHash(pc_mint, coin_mint), slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    -- PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_deposit_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(String) CODEC(LZ4),
    coin_mint LowCardinality(String) CODEC(LZ4),
    lp_mint LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_pair_hash (SELECT * ORDER BY getPairHash(pc_mint, coin_mint), slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    -- PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    pc_mint LowCardinality(String) CODEC(LZ4),
    coin_mint LowCardinality(String) CODEC(LZ4),
    lp_mint LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_pair_hash (SELECT * ORDER BY getPairHash(pc_mint, coin_mint), slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    -- PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_pnl_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    pc_mint LowCardinality(String) CODEC(LZ4),
    coin_mint LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_pair_hash (SELECT * ORDER BY getPairHash(pc_mint, coin_mint), slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    -- PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    decimals UInt64,
    mint_authority LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    multisig String CODEC(LZ4),
    -- signers Array(LowCardinality(String)) CODEC(LZ4),
    m UInt64,
    -- PROJECTION projection_multisig (SELECT * ORDER BY multisig),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    destination_address LowCardinality(String) CODEC(LZ4),
    destination_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    authority LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_source (SELECT * ORDER BY source_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_destination (SELECT * ORDER BY destination_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_approve_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    delegate LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    authority_type LowCardinality(VARCHAR(14)) CODEC(LZ4),
    new_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    destination_address LowCardinality(String) CODEC(LZ4),
    destination_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    mint_authority LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    -- PROJECTION projection_destination (SELECT * ORDER BY destination_owner), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 32e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_burn_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    authority LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 16e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    destination LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    -- PROJECTION projection_destination (SELECT * ORDER BY destination),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 8e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_sync_native_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- SYSTEM PROGRAM EVENTS

CREATE TABLE system_program_create_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    new_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_funding_account (SELECT * ORDER BY funding_account),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    assigned_account LowCardinality(String) CODEC(LZ4),
    owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projectION_owner (SELECT * ORDER BY owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    recipient_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account), -- RECOMMENDED
    PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_create_account_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    created_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_advance_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_withdraw_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    recipient_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_initialize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_authorize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    new_nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account LowCardinality(String) CODEC(LZ4),
    space UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    allocated_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    assigned_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    recipient_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    from_seed String CODEC(LZ4),
    from_owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_funding_account (SELECT * ORDER BY funding_account), -- RECOMMENDED
    -- PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_upgrade_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    name String CODEC(LZ4),
    symbol String CODEC(LZ4),
    uri String CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    bonding_curve LowCardinality(String) CODEC(LZ4),
    associated_bonding_curve LowCardinality(String) CODEC(LZ4),
    metadata LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_user (SELECT * ORDER BY user), -- RECOMMENDED
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_initialize_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_user (SELECT * ORDER BY user), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_set_params_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    fee_recipient LowCardinality(String) CODEC(LZ4),
    initial_virtual_token_reserves UInt64,
    initial_virtual_sol_reserves UInt64,
    initial_real_token_reserves UInt64,
    token_total_supply UInt64,
    fee_basis_points UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    bonding_curve LowCardinality(String) CODEC(LZ4),
    token_amount UInt64,
    direction String CODEC(LZ4),
    sol_amount UInt64,
    virtual_sol_reserves UInt64,
    virtual_token_reserves UInt64,
    real_sol_reserves UInt64,
    real_token_reserves UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    -- PROJECTION projection_user (SELECT * ORDER BY user), -- RECOMMENDED
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 8e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_withdraw_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- MPL TOKEN METADATA EVENTS

CREATE TABLE mpl_token_metadata_create_metadata_account_v3_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    metadata String CODEC(LZ4),
    mint String CODEC(LZ4),
    update_authority String CODEC(LZ4),
    is_mutable Boolean,
    name String,
    symbol String,
    uri String,
    seller_fee_basis_points UInt64,
    PROJECTION projection_symbol (SELECT * ORDER BY symbol), -- RECOMMENDED
    PROJECTION projection_mint (SELECT * ORDER BY mint), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE mpl_token_metadata_other_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    "type" String,
    -- PROJECTION projection_type (SELECT * ORDER BY "type"),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);
