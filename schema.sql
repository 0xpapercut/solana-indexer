-- BLOCKS

CREATE TABLE blocks
(
    slot UInt64,
    parent_slot UInt64,
    block_height UInt64,
    blockhash FixedString(88),
    previous_blockhash FixedString(88),
    block_time DateTime,
    insertion_time DateTime MATERIALIZED now(),
)
ENGINE = MergeTree
PRIMARY KEY slot;

-- TRANSACTIONS

CREATE TABLE transactions
(
    slot UInt64,
    transaction_index UInt64,
    signature FixedString(88),
    number_of_signers UInt8,
    signer0 FixedString(44),
    signer1 String DEFAULT '',
    signer2 String DEFAULT '',
    signer3 String DEFAULT '',
    signer4 String DEFAULT '',
    signer5 String DEFAULT '',
    signer6 String DEFAULT '',
    signer7 String DEFAULT '',
    -- signers Array(FixedString(44)),
    PROJECTION projection_signature (SELECT * ORDER BY signature)
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index);

-- RAYDIUM AMM EVENTS

CREATE TABLE raydium_amm_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    amm LowCardinality(FixedString(44)) CODEC(LZ4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in LowCardinality(FixedString(44)) CODEC(LZ4),
    mint_out LowCardinality(FixedString(44)) CODEC(LZ4),
    direction LowCardinality(FixedString(4)) CODEC(LZ4),
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    PROJECTION projection_amm (SELECT * ORDER BY amm),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_mint_in (SELECT * ORDER BY mint_in),
    PROJECTION projection_mint_out (SELECT * ORDER BY mint_out),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_initialize_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    amm LowCardinality(FixedString(44)) CODEC(LZ4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    pc_init_amount UInt64,
    coin_init_amount UInt64,
    lp_init_amount UInt64,
    pc_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    coin_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    lp_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_deposit_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    amm LowCardinality(FixedString(44)) CODEC(LZ4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    lp_amount UInt64,
    pc_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    coin_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    lp_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    amm LowCardinality(FixedString(44)) CODEC(LZ4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    lp_amount UInt64,
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    pc_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    coin_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    lp_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_pnl_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    amm LowCardinality(FixedString(44)) CODEC(LZ4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    pc_amount UInt64,
    coin_amount UInt64,
    pc_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    coin_mint LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_amm (SELECT * ORDER BY amm),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_pc_mint (SELECT * ORDER BY pc_mint),
    PROJECTION projection_coin_mint (SELECT * ORDER BY coin_mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    decimals UInt64,
    mint_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    freeze_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    account_address LowCardinality(FixedString(44)) CODEC(LZ4),
    account_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    multisig FixedString(44) CODEC(LZ4),
    -- signers Array(LowCardinality(FixedString(44))) CODEC(LZ4),
    m UInt64,
    -- PROJECTION projection_multisig (SELECT * ORDER BY multisig),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    destination_address LowCardinality(FixedString(44)) CODEC(LZ4),
    destination_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    amount UInt64,
    authority LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY (source_owner, destination_owner)),
    -- PROJECTION projection_destination (SELECT * ORDER BY (destination_owner, source_owner)),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_approve_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    delegate LowCardinality(FixedString(44)) CODEC(LZ4),
    amount UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    authority_type LowCardinality(VARCHAR(14)) CODEC(LZ4),
    new_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    destination_address LowCardinality(FixedString(44)) CODEC(LZ4),
    destination_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    mint_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    PROJECTION projection_destination (SELECT * ORDER BY destination_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_burn_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    authority LowCardinality(FixedString(44)) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    destination LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)),
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    PROJECTION projection_source (SELECT * ORDER BY (source_owner, destination)),
    PROJECTION projection_destination (SELECT * ORDER BY (destination, source_owner)),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    freeze_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    source_address LowCardinality(FixedString(44)) CODEC(LZ4),
    source_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    freeze_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    account_address LowCardinality(FixedString(44)) CODEC(LZ4),
    account_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_sync_native_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    account_address LowCardinality(FixedString(44)) CODEC(LZ4),
    account_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

-- SYSTEM PROGRAM EVENTS

CREATE TABLE system_program_create_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    funding_account LowCardinality(FixedString(44)) CODEC(LZ4),
    new_account LowCardinality(FixedString(44)) CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projection_funding_account (SELECT * ORDER BY funding_account),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    assigned_account LowCardinality(FixedString(44)) CODEC(LZ4),
    owner LowCardinality(FixedString(44)) CODEC(LZ4),
    -- PROJECTION projectION_owner (SELECT * ORDER BY owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    funding_account LowCardinality(FixedString(44)) CODEC(LZ4),
    recipient_account LowCardinality(FixedString(44)) CODEC(LZ4),
    lamports UInt64,
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account),
    PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_create_account_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    funding_account LowCardinality(FixedString(44)) CODEC(LZ4),
    created_account LowCardinality(FixedString(44)) CODEC(LZ4),
    base_account LowCardinality(FixedString(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_advance_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    nonce_account LowCardinality(FixedString(44)) CODEC(LZ4),
    nonce_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_withdraw_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    nonce_account LowCardinality(FixedString(44)) CODEC(LZ4),
    nonce_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    recipient_account LowCardinality(FixedString(44)) CODEC(LZ4),
    lamports UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_initialize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    nonce_account LowCardinality(FixedString(44)) CODEC(LZ4),
    nonce_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);


CREATE TABLE system_program_authorize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    nonce_account LowCardinality(FixedString(44)) CODEC(LZ4),
    nonce_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    new_nonce_authority LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    account LowCardinality(FixedString(44)) CODEC(LZ4),
    space UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    allocated_account LowCardinality(FixedString(44)) CODEC(LZ4),
    base_account LowCardinality(FixedString(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    space UInt64,
    owner LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    assigned_account LowCardinality(FixedString(44)) CODEC(LZ4),
    base_account LowCardinality(FixedString(44)) CODEC(LZ4),
    seed String CODEC(LZ4),
    owner LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    funding_account LowCardinality(FixedString(44)) CODEC(LZ4),
    base_account LowCardinality(FixedString(44)) CODEC(LZ4),
    recipient_account LowCardinality(FixedString(44)) CODEC(LZ4),
    lamports UInt64,
    from_seed String CODEC(LZ4),
    from_owner LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account),
    PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_upgrade_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    nonce_account LowCardinality(FixedString(44)) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

-- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    name String CODEC(LZ4),
    symbol String CODEC(LZ4),
    uri String CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    bonding_curve LowCardinality(FixedString(44)) CODEC(LZ4),
    associated_bonding_curve LowCardinality(FixedString(44)) CODEC(LZ4),
    metadata LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_initialize_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_set_params_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    fee_recipient LowCardinality(FixedString(44)) CODEC(LZ4),
    initial_virtual_token_reserves UInt64,
    initial_virtual_sol_reserves UInt64,
    initial_real_token_reserves UInt64,
    token_total_supply UInt64,
    fee_basis_points UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    user LowCardinality(FixedString(44)) CODEC(LZ4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    bonding_curve LowCardinality(FixedString(44)) CODEC(LZ4),
    token_amount UInt64,
    direction String CODEC(LZ4),
    sol_amount UInt64,
    virtual_sol_reserves UInt64,
    virtual_token_reserves UInt64,
    real_sol_reserves UInt64,
    real_token_reserves UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    PROJECTION projection_user (SELECT * ORDER BY user),
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_withdraw_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    mint LowCardinality(FixedString(44)) CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

-- MPL TOKEN METADATA EVENTS

CREATE TABLE mpl_token_metadata_create_metadata_account_v3_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    metadata FixedString(44) CODEC(LZ4),
    mint FixedString(44) CODEC(LZ4),
    update_authority FixedString(44) CODEC(LZ4),
    is_mutable Boolean,
    name String,
    symbol String,
    uri String,
    seller_fee_basis_points UInt64,
    PROJECTION projection_symbol (SELECT * ORDER BY symbol),
    PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);

CREATE TABLE mpl_token_metadata_other_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature FixedString(4),
    partial_blockhash FixedString(4),
    "type" String,
    -- PROJECTION projection_type (SELECT * ORDER BY "type"),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(FixedString(44)) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index);
