use substreams;
use substreams_database_change::pb::database::{table_change::Operation, DatabaseChanges};
use substreams_solana;
use substreams_solana::pb::sf::solana::r#type::v1::Block;
// use substreams_database_change::change::{
//     ToField,
// };

use raydium_substream;
// use spl_token_substream;

#[substreams::handlers::map]
fn db_out(block: Block) ->  Result<DatabaseChanges, substreams::errors::Error> {
    let mut changes = DatabaseChanges::default();

    let transactions = raydium_substream::parse_block(block);
    for transaction in transactions {
        for (i, event) in transaction.events.iter().enumerate() {
            match &event.data {
                Some(raydium_substream::pb::raydium::raydium_event::Data::Swap(swap)) => {
                    changes.push_change("raydium_swap_events", &transaction.signature, i as u64, Operation::Create)
                           .change("signature", (None, &transaction.signature))
                           .change("amm", (None, &event.amm))
                           .change("user", (None, &event.user))
                           .change("amount_in", (None, swap.amount_in))
                           .change("amount_out", (None, swap.amount_out))
                           .change("mint_in", (None, &swap.mint_in))
                           .change("mint_out", (None, &swap.mint_out));
                }
                _ => (),
            }
        }
    }

    Ok(changes)
}
