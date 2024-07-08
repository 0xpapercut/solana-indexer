CREATE TABLE raydium_swap_events
(
    signature VARCHAR(88),
    id UInt64,
    slot UInt64,
    amm VARCHAR(44),
    user VARCHAR(44),
    amount_in UInt64,
    amount_out UInt64,
    mint_in VARCHAR(44),
    mint_out VARCHAR(44),
)
ENGINE = MergeTree
PRIMARY KEY (signature, id)
