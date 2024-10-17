DROP FUNCTION IF EXISTS getPumpfunMigrationRaydiumAMM;
CREATE FUNCTION getPumpfunMigrationRaydiumAMM AS (mint) -> (
    SELECT amm
    FROM transactions a
    JOIN raydium_amm_initialize_events b ON a.slot = b.slot AND a.transaction_index = b.transaction_index
    WHERE (slot, transaction_index) IN (
        SELECT slot, transaction_index
        FROM raydium_amm_initialize_events
        WHERE pc_mint = 'Fosp9yoXQBdx8YqyURZePYzgpCnxp9XsfnQq69DRvvU4' OR coin_mint = 'Fosp9yoXQBdx8YqyURZePYzgpCnxp9XsfnQq69DRvvU4'
    ) AND signer0 = pumpfunRaydiumMigrationSigner()
);

DROP FUNCTION IF EXISTS raydiumAmmProgramID;
CREATE FUNCTION raydiumAmmProgramID AS () -> '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8';

DROP FUNCTION IF EXISTS raydiumAuthority;
CREATE FUNCTION raydiumAuthority AS () -> '5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1';

DROP FUNCTION IF EXISTS pumpfunProgramID;
CREATE FUNCTION pumpfunProgramID AS () -> '6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P';

DROP FUNCTION IF EXISTS pumpfunRaydiumMigrationSigner;
CREATE FUNCTION pumpfunRaydiumMigrationSigner AS () -> '39azUYFWPz3VHgKCf3VChUwbpURdCHRxjWVowf5jUJjg';

DROP FUNCTION IF EXISTS wrappedSolMint;
CREATE FUNCTION wrappedSolMint AS () -> 'So11111111111111111111111111111111111111112';

DROP FUNCTION IF EXISTS jitoTipPaymentAccounts;
CREATE FUNCTION jitoTipPaymentAccounts AS () -> [
    96gYZGLnJYVFmbjzopPSU6QiEV5fGqZNyN9nmNhvrZU5,
    HFqU5x63VTqvQss8hp11i4wVV8bD44PvwucfZ2bU7gRe,
    Cw8CFyM9FkoMi7K7Crf6HNQqf4uEMzpKw6QNghXLvLkY,
    ADaUMid9yfUytqMBgopwjb2DTLSokTSzL1zt6iGPaS49,
    DfXygSm4jCyNCybVYYK6DwvWqjKee8pbDmJGcLWNDXjh,
    ADuUkR4vqLUMWXxW9gh6D6L8pMSawimctcNZ5pGwDcEt,
    DttWaMuVvTiduZRnguLF7jNxTgiMBZ1hyAumKUiL2KRL,
    3AVi9Tg9Uo68tJfuvoKvqKNWKkC5wPdSSdeBnizKZ6jT
];
