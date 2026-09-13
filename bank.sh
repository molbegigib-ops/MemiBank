#!/bin/bash
balance=0
clear
preBankMenu="
                      -Create an account for MemiBank-

Welcome, this is the worlds greatest bank, we steal your money and also
sell your information to complete strangers! But it's okay since we make
funny and silly ads. If you want to sign up for MemiBank, just press 1. If not
then 0. If you have an account you can choose 5.

1) Sign Up
5) Log In
9) Having Issues?
0) Exit
"

showBankMenu() {
    while :; do
        clear
        echo "
                      -Welcome to MemiBank-

Your name: $name
Balance: $balance

1) Deposit
2) Withdraw
3) Transfer (Not Finished)
4) Exit

0) Having Issues?
"

        read -rp "$: " input

        case "$input" in
            1)
                read -rp "Enter the amount you want to Deposit: " depositMoney

                if [[ ! "$depositMoney" =~ ^[0-9]+$ ]]; then
                    echo "Please enter a valid number."
                    sleep 3
                elif (( depositMoney <= 0 )); then
                    echo "You need money to Deposit."
                    sleep 3
                else
                    balance=$((balance + depositMoney))
                    sed -i "/^\[$name's Account\]/,/^$/ s/^    balance=.*/    balance=$balance/" "$accounts"
                fi
            ;;

            2)
                read -rp "Enter the amount you want to Withdraw: " withdrawMoney

                if [[ ! "$withdrawMoney" =~ ^[0-9]+$ ]]; then
                    echo "Please enter a valid number."
                    sleep 3
                elif (( withdrawMoney <= 0 )); then
                    echo "You need valid number to withdraw."
                    sleep 3
                elif (( balance < withdrawMoney )); then
                    echo "You can't withdraw more than your balance."
                    sleep 3
                else
                    balance=$((balance - withdrawMoney))
                    sed -i "/^\[$name's Account\]/,/^$/ s/^    balance=.*/    balance=$balance/" "$accounts"
                fi
            ;;

            3)
              echo "Transfer."
              sleep 2
            ;;

            4)
                clear
                exit
            ;;

            0)
                clear
                echo "You can always contact our technical support. Just call +90:(541)-541-54-10  (Random Numbers)"
                exit
            ;;

            *)
                echo "Something went wrong..."
                sleep 2
            ;;
        esac
    done
}

accounts='/home/memin/MemiBank/Accounts.conf'
if [[ ! -e "$accounts" ]]; then
    echo "Couldn't find save, please try again later."
    exit
fi

echo "$preBankMenu"
read -r pressed

# Sign Up
if [[ "$pressed" == "1" ]]; then
    while :; do
        clear
        read -rp "Your user: " name
        read -rsp "Your password: " password
        echo

        if [[ -z "$name" || -z "$password" ]]; then # If empty
            echo "Invalid."
            continue
        fi

        if [[ ! "$name" =~ ^[a-zA-Z]+$ ]]; then # If numbers in name
            echo "Invalid name."
            continue
        fi

        if [[ ${#password} -lt 4 || ${#password} -gt 12 ]]; then # If ps < 4 | ps > 12
            echo "Invalid password length."
            continue
        fi

        if grep -q "^\[$name's Account\]" "$accounts"; then
            echo "That username already exists."
            sleep 2
            continue
        fi
        break
    done
    
    passwordSHA=$(printf '%s' "$password" | sha256sum | cut -d' ' -f1)
        cat >> "$accounts" << EOF
[$name's Account]
    name=$name
    password=$passwordSHA
    balance=$balance

EOF

echo -e "\nSuccessfully signed up, please log in now."

# Log In
elif [[ "$pressed" == "5" ]]; then
    clear
    echo "                      -Welcome back to MemiBank-"

    read -rp "Your user: " name
    read -rsp "Your password: " password
    echo

    account=$(grep -A 3 "^\[$name's Account\]" "$accounts")
    
    if [[ -z "$account" ]]; then
        echo "Invalid username or password."
        exit
    fi

    passwordLogin=$(echo "$account" | grep '^ *password=' | cut -d= -f2)
    balance=$(echo "$account" | grep '^ *balance=' | cut -d= -f2)

    passwordSHA=$(printf '%s' "$password" | sha256sum | cut -d' ' -f1)

    if [[ "$passwordSHA" == "$passwordLogin" ]]; then
        showBankMenu
    else
        echo "Invalid username or password."
        exit
    fi

# Exit
elif [[ "$pressed" == "9" ]]; then
    clear
    echo "You can always contact our technical support. Just call +90:(541)-541-54-10  (Random Numbers)"
    exit
elif [[ "$pressed" == "0" ]]; then
    echo -e "\nExiting..."
    exit
fi
