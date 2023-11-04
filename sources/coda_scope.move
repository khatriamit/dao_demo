module demo_dao::coda_scope{
  use std::string::{Self, String};
  use std::vector;

  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::tx_context::{Self, TxContext};
  
  // use std::vector;

  struct CodaScopeSet has key, store{
    id: UID,
    authority: String,
    type: String,
    digest: String,
    scopes: vector<String>,
  }

  struct CodaScopeSetCap has key{
    id: UID,
  }

  struct CodaScopeSetRegistry has key, store{
    id: UID,
    CODA_MANAGED: UID,
    CODA_UNMANAGED: UID,
  }

  struct CodaEditScopeRegistryCap has key{
    id: UID,
  }

  struct CodaCreateScopeSetCap has key, store{
    id: UID,
    beneficiay: address,
    authority: String,
    type: String,
  }

  /* 
    ====================================
                CONSTANTS
    ====================================
  */

  const EUnauthorizedScopName: u64 = 0;

  /*
    @requires CodaScopeAdminCap 
    info: this method is used to issue the capability to the beneficiary 
    benificiary: the address to issue cap
  */ 
  public entry fun issue_scope_set_cap(beneficiay:address, authority:String, type: String, ctx: &mut TxContext){
    let object = CodaCreateScopeSetCap{
      id: object::new(ctx),
      beneficiay,
      authority,
      type,
    };
    transfer::transfer(object, beneficiay);
  }


  /*
    @requires CodaCreateScopeSetCap 
    info: this method is used to create CodaScopeSet obj
    owner: method caller is the owner
  */ 
  public entry fun create_scope_set(
    scope_cap: &CodaCreateScopeSetCap, 
    authority:String, 
    digest:String, 
    type: String, 
    scopes:vector<String>,
    ctx: &mut TxContext){
      let scopes_len:u64 = vector::length(&scopes);
      let i:u64 = 0;
      while(i <= scopes_len){
        assert!(&scope_cap.authority == vector::borrow(&scopes, i), EUnauthorizedScopName);
      };
      let scope_set = CodaScopeSet{
        id: object::new(ctx),
        authority,
        type,
        digest,
        scopes,
      };
      transfer::transfer(scope_set, tx_context::sender(ctx));
  }
  
  public entry fun register_scope_set(cap: &CodaEditScopeRegistryCap, scope_set:CodaScopeSet, ctx: &mut TxContext){
    
  }
}