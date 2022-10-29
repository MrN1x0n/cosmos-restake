#!/bin/bash
#Special thanks 4 n0ok!

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

for (( ;; )); do
        BAL=$($NODE_NAME q  bank balances ${DELEGATOR});
        echo -e "BALANCE: ${GREEN}${BAL}${NC} $TIKER\n"
        echo -e "Claim rewards\n"
        echo -e "${PASWD}\n${PASWD}\n" | $NODE_NAME tx distribution withdraw-rewards ${VALIDATOR} --chain-id $CHAIN_ID --from ${WALLET} --gas 200000 --fees 550$TIKER -y 
        for (( timer=10; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
        BAL=$($NODE_NAME query bank balances ${DELEGATOR} --node ${NODE} -o json | jq -r '.balances  | .[].amount');
        BAL=$((BAL-1000000));
        echo -e "BALANCE: ${GREEN}${BAL}${NC} $TIKER\n"
        echo -e "Stake ALL\n"
        echo -e "${PASWD}\n${PASWD}\n" | $NODE_NAME tx staking delegate ${VALIDATOR} ${BAL}$TIKER  --chain-id $CHAIN_ID --from ${WALLET} --gas 200000 --fees 550$TIKER -y 
        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
done
