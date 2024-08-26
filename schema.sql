-- BLOCKS

CREATE TABLE blocks
(
    slot UInt64,
    height UInt64,
    timestamp UInt64,
    blockhash VARCHAR(88),
    previous_blockhash VARCHAR(88),
)
ENGINE = MergeTree
PRIMARY KEY slot;

-- TRANSACTIONS

CREATE TABLE transactions
(
    signature VARCHAR(88),
    transaction_index UInt32,
    slot UInt64,
)
ENGINE = MergeTree
PRIMARY KEY (signature)
ORDER BY (slot, transaction_index);

-- RAYDIUM AMM EVENTS

CREATE TABLE raydium_amm_swap_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    amm LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    mint_out LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    direction LowCardinality(VARCHAR(4)) CODEC(LZ4),
    pool_pc_amount UIn64,
    pool_coin_amount UInt64,
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (amm, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_initialize_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    amm LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    pc_init_amount UInt64,
    coin_init_amount UInt64,
    lp_init_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (amm, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_deposit_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    amm LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (amm, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    amm LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    lp_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (amm, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_pnl_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    amm LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    pc_amount Nullable(UInt64),
    coin_amount Nullable(UInt64),
    pc_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    coin_mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (amm, slot, transaction_index, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    decimals UInt32,
    mint_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    account_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    account_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    instruction_index UInt32,
    transaction_index UInt32,
    multisig VARCHAR(44) CODEC(LZ4),
    -- signers Array(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    m UInt32,
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY multisig;

CREATE TABLE spl_token_transfer_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    amount UInt64,
    authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_source (SELECT * ORDER BY (source_owner, destination_owner)),
    PROJECTION projection_destination (SELECT * ORDER BY (destination_owner, source_owner)),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_approve_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    delegate LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    instruction_index UInt32,
    transaction_index UInt32,
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    authority_type LowCardinality(VARCHAR(14)) CODEC(LZ4),
    new_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    destination_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    mint_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_owner (SELECT * ORDER BY destination_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_burn_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    amount UInt64,
    PROJECTION owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    destination LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)),
    PROJECTION projection_source (SELECT * ORDER BY (source_owner, destination)),
    PROJECTION projection_destination (SELECT * ORDER BY (destination, source_owner)),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    instruction_index UInt32,
    transaction_index UInt32,
    source_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    source_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    freeze_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    account_address LowCardinality(VARCHAR(44)) CODEC(LZ4),
    account_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

-- SYSTEM PROGRAM EVENTS

CREATE TABLE system_program_create_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    funding_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    new_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account)
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY new_account;

CREATE TABLE system_program_assign_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    assigned_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY owner;

CREATE TABLE system_program_transfer_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    funding_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    recipient_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lamports UInt64,
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account)
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (recipient_account, slot, transaction_index, instruction_index);

CREATE TABLE system_program_create_account_with_seed_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    funding_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    created_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    base_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY new_account;

CREATE TABLE system_program_advance_nonce_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    nonce_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    nonce_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY nonce_account;

CREATE TABLE system_program_withdraw_nonce_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    nonce_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    nonce_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    recipient_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lamports UInt64,
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY nonce_account;

CREATE TABLE system_program_initialize_nonce_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    nonce_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    nonce_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY nonce_account;


CREATE TABLE system_program_authorize_nonce_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    nonce_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    nonce_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    new_nonce_authority LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY nonce_account;

CREATE TABLE system_program_allocate_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    space UInt64,
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY account;

CREATE TABLE system_program_allocate_with_seed_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    allocated_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    base_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    space UInt64,
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY allocated_account;

CREATE TABLE system_program_assign_with_seed_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    assigned_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    base_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY allocated_account;

CREATE TABLE system_program_transfer_with_seed_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    assigned_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    base_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY allocated_account;

CREATE TABLE system_program_transfer_with_seed_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    funding_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    base_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    recipient_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    lamports UInt64,
    from_seed String CODEC(LZ4),
    from_owner LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account)
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (recipient_account, slot, transaction_index, instruction_index);

CREATE TABLE system_program_upgrade_nonce_account_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    instruction_index UInt32,
    transaction_index UInt32,
    nonce_account LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY nonce_account;

-- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    name String CODEC(LZ4),
    symbol String CODEC(LZ4),
    uri String CODEC(LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    bonding_curve LowCardinality(VARCHAR(44)) CODEC(LZ4),
    associated_bonding_curve LowCardinality(VARCHAR(44)) CODEC(LZ4),
    metadata LowCardinality(VARCHAR(44)) CODEC(LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (bonding_curve, slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_initialize_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (user, slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_set_params_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    user LowCardinality(VARCHAR(44)) CODEC(LZ4),
    fee_recipient LowCardinality(VARCHAR(44)) CODEC(LZ4),
    initial_virtual_token_reserves UInt64,
    initial_virtual_sol_reserves UInt64,
    initial_real_token_reserves UInt64,
    token_total_supply UInt64,
    fee_basis_points UInt32,
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_swap_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    user LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    mint LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    bonding_curve LowCardinality(VARCHAR(44)) CODEC(Delta, LZ4),
    token_amount UInt64,
    direction String CODEC(LZ4),
    sol_amount Nullable(UInt64),
    virtual_sol_reserves Nullable(UInt64),
    virtual_token_reserves Nullable(UInt64),
    real_sol_reserves Nullable(UInt64),
    real_token_reserves Nullable(UInt64),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (bonding_curve, slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_withdraw_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    mint LowCardinality(VARCHAR(44)) CODEC(LZ4),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

-- MPL TOKEN METADATA EVENTS

CREATE TABLE mpl_token_metadata_create_metadata_account_v3_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    metadata VARCHAR(44) CODEC(LZ4),
    mint VARCHAR(44) CODEC(LZ4),
    update_authority VARCHAR(44) CODEC(LZ4),
    is_mutable Boolean,
    name String,
    symbol String,
    uri String,
    seller_fee_basis_points UInt64,
    PROJECTION projection_symbol (SELECT * ORDER BY symbol),
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (mint, slot, transaction_index, instruction_index);

CREATE TABLE mpl_token_metadata_other_events
(
    signature VARCHAR(88) CODEC(LZ4),
    slot UInt64,
    transaction_index UInt32,
    instruction_index UInt32,
    "type" String,
    parent_instruction_index Nullable(UInt32),
    top_instruction_index Nullable(UInt32),
    parent_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
    top_instruction_program_id Nullable(LowCardinality(VARCHAR(44))) CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (signature, instruction_index)
ORDER BY (type, slot, transaction_index, instruction_index);
