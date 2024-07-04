CREATE TABLE IF NOT EXISTS "raydium_swap_events"
(
    signature VARCHAR(64),
    slot UInt64,
    event_type VARCHAR(10),
    -- events Nested (
    --     amm VARCHAR(64),
    --     user VARCHAR(64),
        -- data Nested (
        --     initialize Nested (
        --         pc_init_amount UInt64,
        --         coin_init_amount UInt64,
        --         lp_init_amount UInt64,
        --         pc_mint VARCHAR(64),
        --         coin_mint VARCHAR(64),
        --         lp_mint VARCHAR(64),
        --         nonce UInt32
        --     ),
        --     deposit Nested (
        --         pc_amount UInt64,
        --         coin_amount UInt64,
        --         lp_amount UInt64
        --     ),
        --     withdraw Nested (
        --         pc_amount UInt64,
        --         coin_amount UInt64,
        --         lp_amount UInt64
        --     ),
        --     swap Nested (
        --         mint_in VARCHAR(64),
        --         mint_out VARCHAR(64),
        --         amount_in UInt64,
        --         amount_out UInt64
        --     )
        -- )
    -- )
)
ENGINE = MergeTree
PRIMARY KEY (hash)
