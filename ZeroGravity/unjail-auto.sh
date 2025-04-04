#!/bin/bash
# Скрипт для автоматической проверки статуса валидатора и выпуска его из тюрьмы

while true; do
    # Получаем статус валидатора (true, если jailed, false — если нет)
    jailed_status=$(0gchaind q staking validator 0gvaloper1xk67j6hett7jfxnanh5qppxa2pjadap8qzct97 --output json | jq -r '.jailed')
    
    echo "Проверка статуса валидатора: jailed = $jailed_status"

    if [ "$jailed_status" = "true" ]; then
        echo "Валидатор в тюрьме! Выполняется команда unjail..."
        # Выполнение команды unjail. Пароль передаётся через echo.
        echo "YOUR_PASSWORD" | 0gchaind tx slashing unjail --from wallet --chain-id zgtendermint_16600-2 --gas-adjustment 1.7 --gas auto --gas-prices 0.003ua0gi -y
    else
        echo "Валидатор не в тюрьме."
    fi
    
    echo "Ожидание 5 минут до следующей проверки..."
    sleep 300  # Пауза 300 секунд (5 минут)
done
