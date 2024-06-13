use openzeppelin::utils::serde::SerializedAppend;
use starknet::{ContractAddress, contract_address_const, account::Call};
use vault::utils::outside_execution::OutsideExecution;

const P256_PUBLIC_KEY: (u256, u256) =
    (
        0xed5784a75391dc43adcd42dbc4c938e80690c75b3f4309049d5076692f8dafe9,
        0x7ed5e8b3d94dd41f677d0e25f6ea5b332495bbdb74923eabbe9e7d2c1d09a08a
    );

const LIMIT: u256 = 0x1000000000000;
const AMOUNT: u256 = 0x123456789;

// Fake value generated by the test runner
const USDC_ADDRESS: felt252 = 0x7880f487915d45e939b41d22488bd30ad3f07ad5da8cb4655f83244c783cdef;

mod P256_SIGNATURE_CLAIM {
    const R: u256 = 0x1d32e5305965591aa1cc73fb275c80fd8b988920dd3913072051b644939c8aac;
    const S: u256 = 0x1c69b101337a6d4707ebe4c024ed51341c2350e3d6882ac85ddf97be9abedd98;
}

mod P256_SIGNATURE_EXECUTE_FROM_OUTSIDE {
    const R: u256 = 0x308c7afff650ae588153e1e05de97c5d9a37303e84c1c7cdaf57f8e9864c3282;
    const S: u256 = 0x5026173a080a8bcd28f125060d129b119b977df90eb5884e2c5fc0e00b93bbda;
}

const PUBLIC_KEY: felt252 = 0x1f3c942d7f492a37608cde0d77b884a5aa9e11d2919225968557370ddb5a5aa;

fn VALID_SIGNATURE_CLAIM() -> Array<felt252> {
    let mut sig = array![];

    sig.append_serde(P256_SIGNATURE_CLAIM::R);
    sig.append_serde(P256_SIGNATURE_CLAIM::S);

    sig
}

fn VALID_SIGNATURE_EXECUTE_FROM_OUTSIDE() -> Array<felt252> {
    let mut sig = array![];

    sig.append_serde(P256_SIGNATURE_EXECUTE_FROM_OUTSIDE::R);
    sig.append_serde(P256_SIGNATURE_EXECUTE_FROM_OUTSIDE::S);

    sig
}

fn INVALID_SIGNATURE() -> Array<felt252> {
    let mut sig = array![];

    sig.append_serde(P256_SIGNATURE_CLAIM::S);
    sig.append_serde(P256_SIGNATURE_CLAIM::R);

    sig
}

//
// ERC20
//

const SUPPLY: u256 = 1_000_000_000_000_000_000; // 1 ETH

const AMOUNT_1: u256 = 1_000_000; // 1 USDC
const AMOUNT_2: u256 = 2_000_000; // 2 USDC

fn NAME() -> ByteArray {
    "NAME"
}

fn SYMBOL() -> ByteArray {
    "SYMBOL"
}

//
// Accounts
//

fn RECIPIENT_1() -> ContractAddress {
    contract_address_const::<'recipient1'>()
}

fn RECIPIENT_2() -> ContractAddress {
    contract_address_const::<'recipient2'>()
}

//
// Outside execution
//

fn OUTSIDE_EXECUTION_DOUBLE_TRANSFER(erc20_address: ContractAddress) -> OutsideExecution {
    let mut calldata1 = array![];
    calldata1.append_serde(RECIPIENT_1());
    calldata1.append_serde(AMOUNT_1);

    let mut calldata2 = array![];
    calldata2.append_serde(RECIPIENT_2());
    calldata2.append_serde(AMOUNT_2);

    let calls = array![
        Call { to: erc20_address, selector: selector!("transfer"), calldata: calldata1.span(), },
        Call { to: erc20_address, selector: selector!("transfer"), calldata: calldata2.span(), }
    ]
        .span();

    OutsideExecution {
        caller: contract_address_const::<'ANY_CALLER'>(),
        nonce: 1,
        execute_after: 0,
        execute_before: 999999999999,
        calls,
    }
}
