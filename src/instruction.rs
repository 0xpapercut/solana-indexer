use std::cell::{Ref, RefCell};
use std::rc::{Rc, Weak};
use anyhow::Error;

use substreams_solana::pb::sf::solana::r#type::v1::ConfirmedTransaction;
use substreams_solana_utils::instruction::{get_structured_instructions, StructuredInstruction, StructuredInstructions};
use substreams_solana_utils::pubkey::PubkeyRef;
use substreams_solana_utils::log::Log;

#[derive(Debug)]
pub struct IndexedInstruction<'a> {
    pub instruction: Rc<StructuredInstruction<'a>>,
    inner_instructions: RefCell<Vec<Rc<Self>>>,
    parent_instruction: RefCell<Option<Weak<Self>>>,
    pub index: i32,
}

#[allow(unused)]
impl<'a> IndexedInstruction<'a> {
    pub fn new(instruction: Rc<StructuredInstruction<'a>>, index: i32) -> Self {
        IndexedInstruction {
            instruction,
            inner_instructions: RefCell::new(Vec::new()),
            parent_instruction: RefCell::new(None),
            index,
        }
    }
    pub fn inner_instructions(&self) -> Ref<Vec<Rc<Self>>> { self.inner_instructions.borrow() }
    pub fn parent_instruction(&self) -> Option<Rc<Self>> { self.parent_instruction.borrow().as_ref().map(|x| x.upgrade().unwrap()) }

    pub fn program_id(&self) -> PubkeyRef<'a> { self.instruction.program_id() }
    pub fn program_id_index(&self) -> u32 { self.instruction.program_id_index() }
    pub fn accounts(&self) -> &Vec<PubkeyRef> { self.instruction.accounts() }
    pub fn data(&self) -> &Vec<u8> { self.instruction.data() }
    pub fn stack_height(&self) -> Option<u32> { self.instruction.stack_height() }
    pub fn logs(&self) -> Ref<Option<Vec<Log<'a>>>> { self.instruction.logs() }

    pub fn top_instruction(&self) -> Option<Rc<Self>> {
        if let Some(instruction) = self.parent_instruction() {
            let mut top_instruction = instruction;
            while let Some(parent_instruction) = top_instruction.parent_instruction() {
                top_instruction = parent_instruction;
            }
            Some(top_instruction)
        } else {
            None
        }
    }
}

pub fn get_indexed_instructions<'a>(transaction: &'a ConfirmedTransaction) -> Result<Vec<Rc<IndexedInstruction<'a>>>, Error> {
    let mut indexed_instructions: Vec<Rc<IndexedInstruction<'a>>> = Vec::new();

    let structured_instructions = get_structured_instructions(transaction).unwrap();
    let mut instruction_stack: Vec<Rc<IndexedInstruction<'a>>> = Vec::new();

    let mut index = 0;
    for instruction in structured_instructions.flattened() {
        while !instruction_stack.is_empty() && instruction_stack.last().unwrap().instruction.stack_height() >= instruction.stack_height() {
            let popped_instruction = instruction_stack.pop().unwrap();
            if instruction_stack.is_empty() {
               indexed_instructions.push(popped_instruction);
            }
        }

        let indexed_instruction = Rc::new(IndexedInstruction::new(instruction, index));
        if let Some(last_instruction) = instruction_stack.last() {
            *indexed_instruction.as_ref().parent_instruction.borrow_mut() = Some(Rc::downgrade(last_instruction));
            last_instruction.inner_instructions.borrow_mut().push(Rc::clone(&indexed_instruction));
        }
        instruction_stack.push(indexed_instruction);

        index += 1;
    }
    while !instruction_stack.is_empty() {
        let popped_instruction = instruction_stack.pop().unwrap();
        if instruction_stack.is_empty() {
           indexed_instructions.push(popped_instruction);
        }
    }

    Ok(indexed_instructions)
}

pub trait IndexedInstructions<'a> {
    fn flattened(&self) -> Vec<Rc<IndexedInstruction<'a>>>;
}

impl<'a> IndexedInstructions<'a> for Vec<Rc<IndexedInstruction<'a>>> {
    fn flattened(&self) -> Vec<Rc<IndexedInstruction<'a>>> {
        let mut instructions: Vec<Rc<IndexedInstruction>> = Vec::new();
        for instruction in self {
            instructions.push(Rc::clone(instruction));
            instructions.extend(instruction.inner_instructions.borrow().flattened().iter().map(Rc::clone));
        }
        instructions
    }
}
