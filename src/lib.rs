use anyhow::{anyhow, Error, Context};

use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::{Row, Tables};
use substreams_solana::pb::sf::solana::r#type::v1::{Block, ConfirmedTransaction};

use substreams_solana_utils::transaction::{get_context, get_signature, get_signers, TransactionContext};
use substreams_solana_utils::system_program::constants::SYSTEM_PROGRAM_ID;
use substreams_solana_utils::spl_token::constants::TOKEN_PROGRAM_ID;

use raydium_amm_substream;
use raydium_amm_substream::raydium_amm::constants::RAYDIUM_AMM_PROGRAM_ID;
use raydium_amm_substream::pb::raydium_amm::raydium_amm_event;

use spl_token_substream;
use spl_token_substream::pb::spl_token::{spl_token_event, AuthorityType};

use mpl_token_metadata_substream;
use mpl_token_metadata_substream::mpl_token_metadata::constants::MPL_TOKEN_METADATA_PROGRAM_ID;
use mpl_token_metadata_substream::pb::mpl_token_metadata::mpl_token_metadata_event;

use pumpfun_substream;
use pumpfun_substream::pumpfun::PUMPFUN_PROGRAM_ID;
use pumpfun_substream::pb::pumpfun::pumpfun_event;

use system_program_substream;
use system_program_substream::pb::system_program::system_program_event;

mod instruction;
use instruction::{get_indexed_instructions, IndexedInstruction, IndexedInstructions};

#[substreams::handlers::map]
fn block_database_changes(block: Block) -> Result<DatabaseChanges, Error> {
    let mut tables = Tables::new();
    for (index, transaction) in block.transactions.iter().enumerate() {
        match parse_transaction(transaction, index as u32, block.slot, &block.blockhash, &mut tables)? {
            true => {
                let signers = get_signers(transaction);
                let row = tables.create_row("transactions", [("slot", block.slot.to_string()), ("transaction_index", index.to_string())])
                    .set("signature", get_signature(transaction))
                    .set("number_of_signers", signers.len().to_string());
                for i in 0..8 {
                    row.set(&format!("signer{i}"), signers.get(i).unwrap_or(&"".into()));
                }
            },
            false => (),
        }
    }
    tables.create_row("blocks", block.slot.to_string())
        .set("parent_slot", block.parent_slot)
        .set("block_height", block.block_height.as_ref().unwrap().block_height)
        .set("blockhash", block.blockhash)
        .set("previous_blockhash", block.previous_blockhash)
        .set("block_time", block.block_time.as_ref().unwrap().timestamp);
   Ok(tables.to_database_changes())
}

fn parse_transaction<'a>(
    transaction: &ConfirmedTransaction,
    transaction_index: u32,
    slot: u64,
    blockhash: &String,
    tables: &mut Tables,
) -> Result<bool, Error> {
    if let Some(_) = transaction.meta.as_ref().unwrap().err {
        return Ok(false);
    }

    let instructions = get_indexed_instructions(transaction)?;
    let context = get_context(transaction)?;

    let mut tables_changed = false;
    for instruction in instructions.flattened().iter() {
        match parse_instruction(instruction, &context, tables, slot, transaction_index).with_context(|| format!("Transaction {}", context.signature))? {
            Some(row) => {
                row
                    .set("partial_signature", &context.signature[0..4])
                    .set("partial_blockhash", &blockhash[0..4]);
                tables_changed = true;
            },
            None => (),
        }
    }

    Ok(tables_changed)
}

fn parse_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let program_id = instruction.program_id();
    let row = if program_id == RAYDIUM_AMM_PROGRAM_ID {
        parse_raydium_amm_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == TOKEN_PROGRAM_ID {
        parse_spl_token_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == SYSTEM_PROGRAM_ID {
        parse_system_program_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == PUMPFUN_PROGRAM_ID {
        parse_pumpfun_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == MPL_TOKEN_METADATA_PROGRAM_ID {
        parse_mpl_token_metadata_instruction(instruction, context, tables, slot, transaction_index)
    } else {
        return Ok(None);
    }?;

    if let Some(row) = row {
        if let Some(parent_instruction) = instruction.parent_instruction() {
            let top_instruction = instruction.top_instruction().unwrap();
            row
                .set("parent_instruction_program_id", parent_instruction.program_id().to_string())
                .set("parent_instruction_index", parent_instruction.index)
                .set("top_instruction_program_id", top_instruction.program_id().to_string())
                .set("top_instruction_index", top_instruction.index);
        } else {
            row
                .set("parent_instruction_program_id", "")
                .set("parent_instruction_index", -1)
                .set("top_instruction_program_id", "")
                .set("top_instruction_index", -1);
        }
        Ok(Some(row))
    } else {
        Ok(None)
    }
}

fn parse_system_program_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let row = match system_program_substream::parse_instruction(&instruction.instruction, context)? {
        Some(system_program_event::Event::CreateAccount(create_account)) => {
            tables.create_row("system_program_create_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("funding_account", create_account.funding_account)
                .set("new_account", create_account.new_account)
                .set("lamports", create_account.lamports)
                .set("space", create_account.space)
                .set("owner", create_account.owner)
        },
        Some(system_program_event::Event::Assign(assign)) => {
            tables.create_row("system_program_assign_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("assigned_account", assign.assigned_account)
                .set("owner", assign.owner)
        },
        Some(system_program_event::Event::Transfer(transfer)) => {
            tables.create_row("system_program_transfer_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("funding_account", transfer.funding_account)
                .set("recipient_account", transfer.recipient_account)
                .set("lamports", transfer.lamports)
        },
        Some(system_program_event::Event::CreateAccountWithSeed(create_account_with_seed)) => {
            tables.create_row("system_program_create_account_with_seed_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("funding_account", create_account_with_seed.funding_account)
                .set("created_account", create_account_with_seed.created_account)
                .set("base_account", create_account_with_seed.base_account)
                .set("seed", create_account_with_seed.seed)
                .set("lamports", create_account_with_seed.lamports)
                .set("space", create_account_with_seed.space)
                .set("owner", create_account_with_seed.owner)
        },
        Some(system_program_event::Event::AdvanceNonceAccount(advance_nonce_account)) => {
            tables.create_row("system_program_advance_nonce_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("nonce_account", advance_nonce_account.nonce_account)
                .set("nonce_authority", advance_nonce_account.nonce_authority)
        },
        Some(system_program_event::Event::WithdrawNonceAccount(withdraw_nonce_account)) => {
            tables.create_row("system_program_withdraw_nonce_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("nonce_account", withdraw_nonce_account.nonce_account)
                .set("nonce_authority", withdraw_nonce_account.nonce_authority)
                .set("recipient_account", withdraw_nonce_account.recipient_account)
                .set("lamports", withdraw_nonce_account.lamports)
        },
        Some(system_program_event::Event::InitializeNonceAccount(initialize_nonce_account)) => {
            tables.create_row("system_program_initialize_nonce_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("nonce_account", initialize_nonce_account.nonce_account)
                .set("nonce_authority", initialize_nonce_account.nonce_authority)
        },
        Some(system_program_event::Event::AuthorizeNonceAccount(authorize_nonce_account)) => {
            tables.create_row("system_program_authorize_nonce_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("nonce_account", authorize_nonce_account.nonce_account)
                .set("nonce_authority", authorize_nonce_account.nonce_authority)
                .set("new_nonce_authority", authorize_nonce_account.new_nonce_authority)
        },
        Some(system_program_event::Event::Allocate(allocate)) => {
            tables.create_row("system_program_allocate_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("account", allocate.account)
                .set("space", allocate.space)
        },
        Some(system_program_event::Event::AllocateWithSeed(allocate_with_seed)) => {
            tables.create_row("system_program_allocate_with_seed_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("allocated_account", allocate_with_seed.allocated_account)
                .set("base_account", allocate_with_seed.base_account)
                .set("seed", allocate_with_seed.seed)
                .set("space", allocate_with_seed.space)
                .set("owner", allocate_with_seed.owner)
        },
        Some(system_program_event::Event::AssignWithSeed(assign_with_seed)) => {
            tables.create_row("system_program_assign_with_seed_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("assigned_account", assign_with_seed.assigned_account)
                .set("base_account", assign_with_seed.base_account)
                .set("seed", assign_with_seed.seed)
                .set("owner", assign_with_seed.owner)
        },
        Some(system_program_event::Event::TransferWithSeed(transfer_with_seed)) => {
            tables.create_row("system_program_transfer_with_seed_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("funding_account", transfer_with_seed.funding_account)
                .set("base_account", transfer_with_seed.base_account)
                .set("recipient_account", transfer_with_seed.recipient_account)
                .set("lamports", transfer_with_seed.lamports)
                .set("from_seed", transfer_with_seed.from_seed)
                .set("from_owner", transfer_with_seed.from_owner)
        },
        Some(system_program_event::Event::UpgradeNonceAccount(upgrade_nonce_account)) => {
            tables.create_row("system_program_upgrade_nonce_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("nonce_account", upgrade_nonce_account.nonce_account)
        },
        None => return Ok(None),
    };
    Ok(Some(row))
}

fn parse_spl_token_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let row = match spl_token_substream::parse_instruction(&instruction.instruction, context)? {
        Some(spl_token_event::Event::InitializeMint(initialize_mint)) => {
            let row = tables.create_row("spl_token_initialize_mint_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("mint", &initialize_mint.mint)
                .set("decimals", initialize_mint.decimals)
                .set("mint_authority", &initialize_mint.mint_authority);
            match &initialize_mint.freeze_authority {
                Some(freeze_authority) => { row.set("freeze_authority", freeze_authority); }
                None => { row.set("freeze_authority", "null".to_string()); }
            }
            row
        },
        Some(spl_token_event::Event::InitializeAccount(initialize_account)) => {
            tables.create_row("spl_token_initialize_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("account_address", &initialize_account.account.as_ref().unwrap().address)
                .set("account_owner", &initialize_account.account.as_ref().unwrap().owner)
                .set("mint", &initialize_account.account.as_ref().unwrap().mint)
        },
        Some(spl_token_event::Event::InitializeMultisig(initialize_multisig)) => {
            tables.create_row("spl_token_initialize_multisig_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("multisig", &initialize_multisig.multisig)
                // .set_clickhouse_array("signers", initialize_multisig.signers.clone())
                .set("m", initialize_multisig.m)
        },
        Some(spl_token_event::Event::Transfer(transfer)) => {
            tables.create_row("spl_token_transfer_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &transfer.source.as_ref().unwrap().address)
                .set("source_owner", &transfer.source.as_ref().unwrap().owner)
                .set("destination_address", &transfer.destination.as_ref().unwrap().address)
                .set("destination_owner", &transfer.destination.as_ref().unwrap().owner)
                .set("mint", &transfer.source.as_ref().unwrap().mint)
                .set("authority", &transfer.authority)
                .set("amount", transfer.amount)
                .set("source_pre_balance", transfer.source.as_ref().unwrap().pre_balance.unwrap_or(0))
                .set("destination_pre_balance", transfer.source.as_ref().unwrap().pre_balance.unwrap_or(0))
        },
        Some(spl_token_event::Event::Approve(approve)) => {
            tables.create_row("spl_token_approve_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &approve.source.as_ref().unwrap().address)
                .set("source_owner", &approve.source.as_ref().unwrap().owner)
                .set("mint", &approve.source.as_ref().unwrap().mint)
                .set("delegate", &approve.delegate)
                .set("amount", approve.amount)
        },
        Some(spl_token_event::Event::Revoke(revoke)) => {
            tables.create_row("spl_token_revoke_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &revoke.source.as_ref().unwrap().address)
                .set("source_owner", &revoke.source.as_ref().unwrap().owner)
                .set("mint", &revoke.source.as_ref().unwrap().mint)
        },
        Some(spl_token_event::Event::SetAuthority(set_authority)) => {
            let row = tables.create_row("spl_token_set_authority_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("mint", &set_authority.mint)
                .set("authority_type", AuthorityType::from_i32(set_authority.authority_type).unwrap().as_str_name());
            match &set_authority.new_authority {
                Some(new_authority) => { row.set("new_authority", new_authority); }
                None => { row.set("new_authority", "null".to_string()); }
            }
            row
        },
        Some(spl_token_event::Event::MintTo(mint_to)) => {
            tables.create_row("spl_token_mint_to_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("destination_address", &mint_to.destination.as_ref().unwrap().address)
                .set("destination_owner", &mint_to.destination.as_ref().unwrap().owner)
                .set("mint", &mint_to.mint)
                .set("mint_authority", &mint_to.mint_authority)
                .set("amount", mint_to.amount)
                .set("destination_pre_balance", mint_to.destination.unwrap().pre_balance.unwrap_or(0))
        },
        Some(spl_token_event::Event::Burn(burn)) => {
            tables.create_row("spl_token_burn_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &burn.source.as_ref().unwrap().address)
                .set("source_owner", &burn.source.as_ref().unwrap().owner)
                .set("mint", &burn.source.as_ref().unwrap().mint)
                .set("amount", burn.amount)
                .set("authority", &burn.authority)
                .set("source_pre_balance", burn.source.unwrap().pre_balance.unwrap_or(0))
        },
        Some(spl_token_event::Event::CloseAccount(close_account)) => {
            tables.create_row("spl_token_close_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &close_account.source.as_ref().unwrap().address)
                .set("source_owner", &close_account.source.as_ref().unwrap().owner)
                .set("destination", &close_account.destination)
                .set("mint", &close_account.source.as_ref().unwrap().mint)
        },
        Some(spl_token_event::Event::FreezeAccount(freeze_account)) => {
            tables.create_row("spl_token_freeze_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &freeze_account.source.as_ref().unwrap().address)
                .set("source_owner", &freeze_account.source.as_ref().unwrap().owner)
                .set("mint", &freeze_account.source.as_ref().unwrap().mint)
                .set("freeze_authority", &freeze_account.freeze_authority)
        },
        Some(spl_token_event::Event::ThawAccount(thaw_account)) => {
            tables.create_row("spl_token_thaw_account_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("source_address", &thaw_account.source.as_ref().unwrap().address)
                .set("source_owner", &thaw_account.source.as_ref().unwrap().owner)
                .set("mint", &thaw_account.source.as_ref().unwrap().mint)
                .set("freeze_authority", &thaw_account.freeze_authority)
        },
        Some(spl_token_event::Event::InitializeImmutableOwner(initialize_immutable_owner)) => {
            tables.create_row("spl_token_initialize_immutable_owner_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("account_address", &initialize_immutable_owner.account.as_ref().unwrap().address)
                .set("account_owner", &initialize_immutable_owner.account.as_ref().unwrap().owner)
                .set("mint", &initialize_immutable_owner.account.as_ref().unwrap().mint)
        },
        Some(spl_token_event::Event::SyncNative(sync_native)) => {
            tables.create_row("spl_token_sync_native_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("account_address", &sync_native.account.as_ref().unwrap().address)
                .set("account_owner", &sync_native.account.as_ref().unwrap().owner)
        }
        None => return Ok(None)
    };
    Ok(Some(row))
}

fn parse_raydium_amm_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let row = match raydium_amm_substream::parse_instruction(&instruction.instruction, context).map_err(|x| anyhow!(x))? {
        Some(raydium_amm_event::Event::Swap(swap)) => {
            tables.create_row("raydium_amm_swap_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &swap.amm)
                .set("user", &swap.user)
                .set("amount_in", swap.amount_in)
                .set("amount_out", swap.amount_out)
                .set("mint_in", &swap.mint_in)
                .set("mint_out", &swap.mint_out)
                .set("direction", &swap.direction)
                .set("pool_pc_amount", swap.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", swap.pool_coin_amount.unwrap_or(0))
                .set("user_pre_balance_in", swap.user_pre_balance_in.unwrap_or(0))
                .set("user_pre_balance_out", swap.user_pre_balance_out.unwrap_or(0))
        }
        Some(raydium_amm_event::Event::Initialize(initialize)) => {
            tables.create_row("raydium_amm_initialize_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &initialize.amm)
                .set("user", &initialize.user)
                .set("pc_init_amount", initialize.pc_init_amount)
                .set("coin_init_amount", initialize.coin_init_amount)
                .set("lp_init_amount", initialize.lp_init_amount)
                .set("pc_mint", &initialize.pc_mint)
                .set("coin_mint", &initialize.coin_mint)
                .set("lp_mint", &initialize.lp_mint)
                .set("user_pc_pre_balance", initialize.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", initialize.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::Deposit(deposit)) => {
            tables.create_row("raydium_amm_deposit_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &deposit.amm)
                .set("user", &deposit.user)
                .set("pc_amount", deposit.pc_amount)
                .set("coin_amount", deposit.coin_amount)
                .set("pool_pc_amount", deposit.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", deposit.pool_coin_amount.unwrap_or(0))
                .set("lp_amount", deposit.lp_amount)
                .set("pc_mint", &deposit.pc_mint)
                .set("coin_mint", &deposit.coin_mint)
                .set("lp_mint", &deposit.lp_mint)
                .set("user_pc_pre_balance", deposit.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", deposit.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::Withdraw(withdraw)) => {
            tables.create_row("raydium_amm_withdraw_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &withdraw.amm)
                .set("user", &withdraw.user)
                .set("pc_amount", withdraw.pc_amount)
                .set("coin_amount", withdraw.coin_amount)
                .set("pool_pc_amount", withdraw.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", withdraw.pool_coin_amount.unwrap_or(0))
                .set("lp_amount", withdraw.lp_amount)
                .set("pc_mint", &withdraw.pc_mint)
                .set("coin_mint", &withdraw.coin_mint)
                .set("lp_mint", &withdraw.lp_mint)
                .set("user_pc_pre_balance", withdraw.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", withdraw.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::WithdrawPnl(withdraw_pnl)) => {
            tables.create_row("raydium_amm_withdraw_pnl_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", withdraw_pnl.amm)
                .set("user", withdraw_pnl.user)
                .set("pc_amount", withdraw_pnl.pc_amount.unwrap_or(0))
                .set("coin_amount", withdraw_pnl.coin_amount.unwrap_or(0))
                .set("pc_mint", withdraw_pnl.pc_mint.unwrap_or("".to_string()))
                .set("coin_mint", withdraw_pnl.coin_mint.unwrap_or("".to_string()))
        }
        _ => return Ok(None),
    };
    Ok(Some(row))
}

fn parse_pumpfun_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let row = match pumpfun_substream::parse_instruction(&instruction.instruction, context)? {
        Some(pumpfun_event::Event::Create(create)) => {
            tables.create_row("pumpfun_create_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", create.user)
                .set("name", create.name)
                .set("symbol", create.symbol)
                .set("uri", create.uri)
                .set("mint", create.mint)
                .set("bonding_curve", create.bonding_curve)
                .set("associated_bonding_curve", create.associated_bonding_curve)
                .set("metadata", create.metadata)
        },
        Some(pumpfun_event::Event::Initialize(initialize)) => {
            tables.create_row("pumpfun_initialize_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", initialize.user)
        },
        Some(pumpfun_event::Event::SetParams(set_params)) => {
            tables.create_row("pumpfun_set_params_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", set_params.user)
                .set("fee_recipient", set_params.fee_recipient)
                .set("initial_virtual_token_reserves", set_params.initial_virtual_token_reserves)
                .set("initial_virtual_sol_reserves", set_params.initial_virtual_sol_reserves)
                .set("initial_real_token_reserves", set_params.initial_real_token_reserves)
                .set("token_total_supply", set_params.token_total_supply)
                .set("fee_basis_points", set_params.fee_basis_points)
        },
        Some(pumpfun_event::Event::Swap(swap)) => {
            tables.create_row("pumpfun_swap_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", swap.user)
                .set("mint", swap.mint)
                .set("bonding_curve", swap.bonding_curve)
                .set("token_amount", swap.token_amount)
                .set("direction", swap.direction)
                .set("sol_amount", swap.sol_amount.unwrap_or(0))
                .set("virtual_sol_reserves", swap.virtual_sol_reserves.unwrap_or(0))
                .set("virtual_token_reserves", swap.virtual_token_reserves.unwrap_or(0))
                .set("real_sol_reserves", swap.real_sol_reserves.unwrap_or(0))
                .set("real_token_reserves", swap.real_token_reserves.unwrap_or(0))
        },
        Some(pumpfun_event::Event::Withdraw(withdraw)) => {
            tables.create_row("pumpfun_withdraw_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("mint", withdraw.mint)
        },
        None => return Ok(None)
    };
    Ok(Some(row))
}

fn parse_mpl_token_metadata_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let row = match mpl_token_metadata_substream::parse_instruction(&instruction.instruction, context).map_err(|x| anyhow!(x))? {
        Some(mpl_token_metadata_event::Event::CreateMetadataAccountV3(create_metadata_account_v3)) => {
            let data = create_metadata_account_v3.data.unwrap();
            let row = tables.create_row("mpl_token_metadata_create_metadata_account_v3_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("metadata", create_metadata_account_v3.metadata)
                .set("mint", create_metadata_account_v3.mint)
                .set("update_authority", create_metadata_account_v3.update_authority)
                .set("is_mutable", create_metadata_account_v3.is_mutable)
                .set("name", data.name)
                .set("symbol", data.symbol)
                .set("uri", data.uri)
                .set("seller_fee_basis_points", data.seller_fee_basis_points);
            row
        },
        Some(mpl_token_metadata_event::Event::ApproveCollectionAuthority(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "approve_collection_authority")
        },
        Some(mpl_token_metadata_event::Event::ApproveUseAuthority(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "approve_use_authority")
        },
        Some(mpl_token_metadata_event::Event::BubblegumSetCollectionSize(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "bubblegum_set_collection_size")
        },
        Some(mpl_token_metadata_event::Event::Burn(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "burn")
        },
        Some(mpl_token_metadata_event::Event::BurnEditionNft(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "burn_edition_nft")
        },
        Some(mpl_token_metadata_event::Event::BurnNft(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "burn_nft")
        },
        Some(mpl_token_metadata_event::Event::CloseEscrowAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "close_escrow_account")
        },
        Some(mpl_token_metadata_event::Event::ConvertMasterEditionV1ToV2(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "convert_master_edition_v1_to_v2")
        },
        Some(mpl_token_metadata_event::Event::Create(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create")
        },
        Some(mpl_token_metadata_event::Event::CreateEscrowAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create_escrow_account")
        },
        Some(mpl_token_metadata_event::Event::CreateMasterEdition(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create_master_edition")
        },
        Some(mpl_token_metadata_event::Event::CreateMasterEditionV3(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create_master_edition_v3")
        },
        Some(mpl_token_metadata_event::Event::CreateMetadataAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create_metadata_account")
        },
        Some(mpl_token_metadata_event::Event::CreateMetadataAccountV2(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "create_metadata_account_v2")
        },
        Some(mpl_token_metadata_event::Event::Delegate(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "delegate")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedCreateMasterEdition(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_create_master_edition")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedCreateReservationList(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_create_reservation_list")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedMintNewEditionFromMasterEditionViaPrintingToken(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_mint_new_edition_from_master_edition_via_printing_token")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedMintPrintingTokens(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_mint_printing_tokens")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedMintPrintingTokensViaToken(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_mint_printing_tokens_via_token")
        },
        Some(mpl_token_metadata_event::Event::DeprecatedSetReservationList(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "deprecated_set_reservation_list")
        },
        Some(mpl_token_metadata_event::Event::FreezeDelegatedAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "freeze_delegated_account")
        },
        Some(mpl_token_metadata_event::Event::Lock(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "lock")
        },
        Some(mpl_token_metadata_event::Event::Migrate(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "migrate")
        },
        Some(mpl_token_metadata_event::Event::MintNewEditionFromMasterEditionViaToken(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "mint_new_edition_from_master_edition_via_token")
        },
        Some(mpl_token_metadata_event::Event::MintNewEditionFromMasterEditionViaVaultProxy(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "mint_new_edition_from_master_edition_via_vault_proxy")
        },
        Some(mpl_token_metadata_event::Event::PuffMetadata(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "puff_metadata")
        },
        Some(mpl_token_metadata_event::Event::RemoveCreatorVerification(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "remove_creator_verification")
        },
        Some(mpl_token_metadata_event::Event::Revoke(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "revoke")
        },
        Some(mpl_token_metadata_event::Event::RevokeCollectionAuthority(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "revoke_collection_authority")
        },
        Some(mpl_token_metadata_event::Event::RevokeUseAuthority(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "revoke_use_authority")
        },
        Some(mpl_token_metadata_event::Event::SetAndVerifyCollection(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "set_and_verify_collection")
        },
        Some(mpl_token_metadata_event::Event::SetAndVerifySizedCollectionItem(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "set_and_verify_sized_collection_item")
        },
        Some(mpl_token_metadata_event::Event::SetTokenStandard(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "set_token_standard")
        },
        Some(mpl_token_metadata_event::Event::SignMetadata(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "sign_metadata")
        },
        Some(mpl_token_metadata_event::Event::ThawDelegatedAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "thaw_delegated_account")
        },
        Some(mpl_token_metadata_event::Event::Transfer(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "transfer")
        },
        Some(mpl_token_metadata_event::Event::TransferOutOfEscrow(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "transfer_out_of_escrow")
        },
        Some(mpl_token_metadata_event::Event::Unlock(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "unlock")
        },
        Some(mpl_token_metadata_event::Event::Unverify(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "unverify")
        },
        Some(mpl_token_metadata_event::Event::UnverifyCollection(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "unverify_collection")
        },
        Some(mpl_token_metadata_event::Event::UnverifySizedCollectionItem(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "unverify_sized_collection_item")
        },
        Some(mpl_token_metadata_event::Event::Update(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "update")
        },
        Some(mpl_token_metadata_event::Event::UpdateMetadataAccount(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "update_metadata_account")
        },
        Some(mpl_token_metadata_event::Event::UpdateMetadataAccountV2(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "update_metadata_account_v2")
        },
        Some(mpl_token_metadata_event::Event::UpdatePrimarySaleHappenedViaToken(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "update_primary_sale_happened_via_token")
        },
        Some(mpl_token_metadata_event::Event::Utilize(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "utilize")
        },
        Some(mpl_token_metadata_event::Event::Print(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "print")
        },
        Some(mpl_token_metadata_event::Event::Verify(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "verify")
        },
        Some(mpl_token_metadata_event::Event::Mint(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "mint")
        },
        Some(mpl_token_metadata_event::Event::SetCollectionSize(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "set_collection_size")
        },
        Some(mpl_token_metadata_event::Event::Collect(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "collect")
        },
        Some(mpl_token_metadata_event::Event::Use(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "use")
        },
        Some(mpl_token_metadata_event::Event::VerifySizedCollectionItem(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "verify_sized_collection_item")
        },
        Some(mpl_token_metadata_event::Event::VerifyCollection(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "verify_collection")
        },
        Some(mpl_token_metadata_event::Event::Resize(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "resize")
        },
        Some(mpl_token_metadata_event::Event::CloseAccounts(_)) => {
            tables.create_row("mpl_token_metadata_other_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("type", "close_accounts")
        }
        None => return Ok(None),
    };
    Ok(Some(row))
}
