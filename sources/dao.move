module demo_dao::dao{
  use std::string::{Self, String};
  use std::vector;
  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::tx_context::{Self, TxContext};
  use sui::vec_map::{Self, VecMap};

  struct Wallet has key{
    id: UID,
    owner: address,
    name:String,
    threshold:u8,
    members: VecMap<address, bool>,
    proposals: vector<Proposal>,
  }

  struct Proposal has store {
    id: UID,
    creator: address,
    votes: VecMap<address, bool>,
    votes_count: u8,
    executed: bool,
  }

  const ENotEnoughVoteCount:u64 = 0;
  const ENotDaoMember:u64 = 1;

  public entry fun create_dao_wallet(name:vector<u8>, threshold:u8, ctx: &mut TxContext){
    let owner = tx_context::sender(ctx);
    let wallet = Wallet{
      id: object::new(ctx),
      owner: owner,
      name: string::utf8(name),
      threshold,
      members: vec_map::empty(),
      proposals: vector::empty(),
    };

    transfer::share_object(wallet);
  }

  public entry fun create_dao_proposal(wallet:&mut Wallet, ctx: &mut TxContext){
    let proposal = Proposal{
      id: object::new(ctx),
      creator: tx_context::sender(ctx),
      votes: vec_map::empty(),
      votes_count: 0,
      executed: false,
    };
    vector::push_back(&mut wallet.proposals, proposal);
  }

  public entry fun add_member(wallet: &mut Wallet, new_member: address){
    vec_map::insert(&mut wallet.members, new_member, true);
  }

  public entry fun approve_proposal(wallet: &mut Wallet, proposal_id: u64, ctx: &mut TxContext){
      let sender = tx_context::sender(ctx);
      assert!(vec_map::contains(&mut wallet.members, &sender)== true, ENotDaoMember);
      let proposal = vector::borrow_mut(&mut wallet.proposals, proposal_id);
      proposal.votes_count = proposal.votes_count + 1;
      vec_map::insert(&mut proposal.votes, tx_context::sender(ctx), true);
  }

  public entry fun execute(wallet: &mut Wallet, proposal_id: u64){
    let proposal = vector::borrow_mut(&mut wallet.proposals, proposal_id);
    assert!(proposal.votes_count >=  wallet.threshold, ENotEnoughVoteCount);
  }

}