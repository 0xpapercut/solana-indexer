use substreams;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;
use substreams_solana;
use substreams_solana::pb::sf::solana::r#type::v1::Block;

use raydium_substream;
use raydium_substream::pb::raydium::raydium_event;

use spl_token_substream;
use spl_token_substream::pb::spl_token::{spl_token_event, AuthorityType};

#[substreams::handlers::map]
fn db_out(block: Block) ->  Result<DatabaseChanges, substreams::errors::Error> {
    let mut changes = DatabaseChanges::default();
    changes.table_changes.extend(raydium_db_out(&block)?.table_changes);
    changes.table_changes.extend(spl_token_db_out(&block)?.table_changes);
    Ok(changes)
}

fn raydium_db_out(block: &Block) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();
    for transaction in raydium_substream::parse_block(block) {
        for (j, event) in transaction.events.iter().enumerate() {
            match &event.event {
                Some(raydium_event::Event::Swap(swap)) => {
                    tables.create_row("raydium_swap_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("amm", &swap.amm)
                          .set("user", &swap.user)
                          .set("amount_in", swap.amount_in)
                          .set("amount_out", swap.amount_out)
                          .set("mint_in", &swap.mint_in)
                          .set("mint_out", &swap.mint_out);
                }
                Some(raydium_event::Event::Initialize(initialize)) => {
                    tables.create_row("raydium_initialize_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("amm", &initialize.amm)
                          .set("user", &initialize.user)
                          .set("pc_init_amount", initialize.pc_init_amount)
                          .set("coin_init_amount", initialize.coin_init_amount)
                          .set("lp_init_amount", initialize.lp_init_amount)
                          .set("pc_mint", &initialize.pc_mint)
                          .set("coin_mint", &initialize.coin_mint)
                          .set("lp_mint", &initialize.lp_mint);
                },
                Some(raydium_event::Event::Deposit(deposit)) => {
                    tables.create_row("raydium_deposit_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("amm", &deposit.amm)
                          .set("user", &deposit.user)
                          .set("pc_amount", deposit.pc_amount)
                          .set("coin_amount", deposit.coin_amount)
                          .set("lp_amount", deposit.lp_amount)
                          .set("pc_mint", &deposit.pc_mint)
                          .set("coin_mint", &deposit.coin_mint)
                          .set("lp_mint", &deposit.lp_mint);
                },
                Some(raydium_event::Event::Withdraw(withdraw)) => {
                    tables.create_row("raydium_withdraw_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("amm", &withdraw.amm)
                          .set("user", &withdraw.user)
                          .set("pc_amount", withdraw.pc_amount)
                          .set("coin_amount", withdraw.coin_amount)
                          .set("lp_amount", withdraw.lp_amount)
                          .set("pc_mint", &withdraw.pc_mint)
                          .set("coin_mint", &withdraw.coin_mint)
                          .set("lp_mint", &withdraw.lp_mint);
                }
                None => ()
            }
        }
    }
    Ok(tables.to_database_changes())
}

fn spl_token_db_out(block: &Block) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();
    for transaction in spl_token_substream::parse_block(block) {
        for (j, event) in transaction.events.iter().enumerate() {
            match &event.event {
                Some(spl_token_event::Event::InitializeMint(initialize_mint)) => {
                    let row = tables.create_row("spl_token_initialize_mint_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                                              .set("slot", block.slot)
                                              .set("mint", &initialize_mint.mint)
                                              .set("decimals", initialize_mint.decimals)
                                              .set("mint_authority", &initialize_mint.mint_authority);
                    if let Some(freeze_authority) = &initialize_mint.freeze_authority {
                        row.set("freeze_authority", freeze_authority);
                    }
                },
                Some(spl_token_event::Event::InitializeAccount(initialize_account)) => {
                    tables.create_row("spl_token_initialize_account_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("account_address", &initialize_account.account.as_ref().unwrap().address)
                          .set("account_owner", &initialize_account.account.as_ref().unwrap().owner)
                          .set("mint", &initialize_account.account.as_ref().unwrap().mint);
                },
                Some(spl_token_event::Event::InitializeMultisig(initialize_multisig)) => {
                    tables.create_row("spl_token_initialize_multisig_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("multisig", &initialize_multisig.multisig)
                          .set_clickhouse_array("signers", initialize_multisig.signers.clone());
                },
                Some(spl_token_event::Event::Transfer(transfer)) => {
                    tables.create_row("spl_token_transfer_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &transfer.source.as_ref().unwrap().address)
                          .set("source_owner", &transfer.source.as_ref().unwrap().owner)
                          .set("destination_address", &transfer.destination.as_ref().unwrap().address)
                          .set("destination_owner", &transfer.destination.as_ref().unwrap().owner)
                          .set("mint", &transfer.source.as_ref().unwrap().mint)
                          .set("authority", &transfer.authority)
                          .set("amount", transfer.amount);
                },
                Some(spl_token_event::Event::Approve(approve)) => {
                    tables.create_row("spl_token_approve_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &approve.source.as_ref().unwrap().address)
                          .set("source_owner", &approve.source.as_ref().unwrap().owner)
                          .set("mint", &approve.source.as_ref().unwrap().mint)
                          .set("delegate", &approve.delegate)
                          .set("amount", approve.amount);
                },
                Some(spl_token_event::Event::Revoke(revoke)) => {
                    tables.create_row("spl_token_revoke_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &revoke.source.as_ref().unwrap().address)
                          .set("source_owner", &revoke.source.as_ref().unwrap().owner)
                          .set("mint", &revoke.source.as_ref().unwrap().mint);
                },
                Some(spl_token_event::Event::SetAuthority(set_authority)) => {
                    let row = tables.create_row("spl_token_set_authority_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                                    .set("slot", block.slot)
                                    .set("mint", &set_authority.mint)
                                    .set("authority_type", AuthorityType::from_i32(set_authority.authority_type).unwrap().as_str_name());
                    if let Some(new_authority) = &set_authority.new_authority {
                        row.set("new_authority", new_authority);
                    }
                },
                Some(spl_token_event::Event::MintTo(mint_to)) => {
                    tables.create_row("spl_token_mint_to_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("destination_address", &mint_to.destination.as_ref().unwrap().address)
                          .set("destination_owner", &mint_to.destination.as_ref().unwrap().owner)
                          .set("mint", &mint_to.mint)
                          .set("mint_authority", &mint_to.mint_authority)
                          .set("amount", mint_to.amount);
                },
                Some(spl_token_event::Event::Burn(burn)) => {
                    tables.create_row("spl_token_burn_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &burn.source.as_ref().unwrap().address)
                          .set("source_owner", &burn.source.as_ref().unwrap().owner)
                          .set("mint", &burn.source.as_ref().unwrap().mint)
                          .set("amount", burn.amount)
                          .set("authority", &burn.authority);
                },
                Some(spl_token_event::Event::CloseAccount(close_account)) => {
                    tables.create_row("spl_token_close_account_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &close_account.source.as_ref().unwrap().address)
                          .set("source_owner", &close_account.source.as_ref().unwrap().owner)
                          .set("destination", &close_account.destination)
                          .set("mint", &close_account.source.as_ref().unwrap().mint);
                },
                Some(spl_token_event::Event::FreezeAccount(freeze_account)) => {
                    tables.create_row("spl_token_freeze_account_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &freeze_account.source.as_ref().unwrap().address)
                          .set("source_owner", &freeze_account.source.as_ref().unwrap().owner)
                          .set("mint", &freeze_account.source.as_ref().unwrap().mint)
                          .set("freeze_authority", &freeze_account.freeze_authority);
                },
                Some(spl_token_event::Event::ThawAccount(thaw_account)) => {
                    tables.create_row("spl_token_thaw_account_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("source_address", &thaw_account.source.as_ref().unwrap().address)
                          .set("source_owner", &thaw_account.source.as_ref().unwrap().owner)
                          .set("mint", &thaw_account.source.as_ref().unwrap().mint)
                          .set("freeze_authority", &thaw_account.freeze_authority);
                },
                Some(spl_token_event::Event::InitializeImmutableOwner(initialize_immutable_owner)) => {
                    tables.create_row("spl_token_initialize_immutable_owner_events", [("signature", transaction.signature.clone()), ("event_id", j.to_string())])
                          .set("slot", block.slot)
                          .set("account_address", &initialize_immutable_owner.account.as_ref().unwrap().address)
                          .set("account_owner", &initialize_immutable_owner.account.as_ref().unwrap().owner)
                          .set("mint", &initialize_immutable_owner.account.as_ref().unwrap().mint);
                },
                _ => (),
            }
        }
    }
    Ok(tables.to_database_changes())
}
