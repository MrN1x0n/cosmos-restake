#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DELAY=3600 # 1 hour
DENOM=1000000

for (( ;; )); do
        BAL=$(${NODE_NAME} query bank balances ${ADDRESS} -o json | jq -r --arg TIKER $TIKER '.balances[] | select(.denom==$TIKER) | .amount');
        COMMISSION_U=$(${NODE_NAME} query distribution commission ${VALOPER} --output json | jq '.commission[] | select(.denom == "'"$TIKER"'") .amount' | bc)
        REWARDS_U=$(${NODE_NAME} query distribution rewards ${ADDRESS} --output json | jq '.total[] | select(.denom == "'"$TIKER"'") .amount' | bc)
        REWARDS_TOTAL_U=$(echo "(${COMMISSION_U}+${REWARDS_U}+${BAL})/1" | bc)

        if (( ${REWARDS_TOTAL_U} > ${DENOM} )); then
                ${NODE_NAME} tx distribution withdraw-rewards ${VALOPER} --from ${WALLET} --commission --fees 200${TIKER} -y
                for (( timer=10; timer>0; timer-- ))
                do
                        printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                        sleep 1
                done

                # Leave 1 TIKER on our balance for commission
                BAL=$((BAL-DENOM));
                echo -e "BALANCE: ${GREEN}${BAL}${NC} ${TIKER}\n"
                echo -e "Stake ALL\n"
                if (( ${BAL} > $DENOM )); then
                        ${NODE_NAME} tx staking delegate ${VALOPER} ${BAL}${TIKER} --from ${WALLET} --fees 200${TIKER} -y 
                else
                        echo -e "BALANCE: ${GREEN_COLOR}${BAL}${NC} ${TIKER} ${BAL} < $DENOM\n"
                fi
        else
                echo -e "BALANCE: ${GREEN_COLOR}${BAL}${NC}${TIKER} | ${BAL} < ${DENOM}"
                echo -e "The balance is too small for staking\n"
        fi

        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
done
