#!/bin/bash

tests() 
{
    start_coffee_server
    send 'REGISTER JOHN 11AA11'
    result_equals 'OK'
    is_in_user_db 'JOHN 11AA11'

    start_coffee_server
    send 'REGISTER JOHN 22AA22'
    result_equals 'ALREADY_REGISTERED'
    is_in_user_db 'JOHN 11AA11'
    is_not_in_user_db 'JOHN 22AA22'

    start_coffee_server
    send 'TAKE_BREWED JOHN AA11AA'
    result_equals 'WRONG_PASSWORD'

    start_coffee_server
    send 'TAKE_BREWED JOHN 11AA11'
    result_equals 'NOTHING_BREWED'

    start_coffee_server
    send 'BREW JOHN AA11AA'
    result_equals 'WRONG_PASSWORD'

    start_coffee_server
    send 'BREW JOHN 11AA11'
    result_equals 'BREWING'
    coffee_brewed_for 'JOHN 11AA11'

    start_coffee_server
    send 'BREW JOHN 11AA11'
    result_equals 'ALREADY_BREWED'
    coffee_brewed_for 'JOHN 11AA11'

    start_coffee_server
    send 'TAKE_BREWED JOHN 11AA11'
    result_equals 'COFFEE_REMOVED'
    no_coffee_brewed_for 'JOHN 11AA11'

    start_coffee_server
    send 'DEREGISTER JOHN AA11AA'
    result_equals 'WRONG_PASSWORD'

    start_coffee_server
    send 'DEREGISTER JOHN 11AA11'
    result_equals 'OK'
    is_not_in_user_db 'JOHN 11AA11'

    start_coffee_server
    send 'UNSUPPORTED COMMAND FROM USER'
    result_equals 'UNKNOWN_COMMAND'

    remove_user_db
    remove_brewed_db
    echo ''
}

send() { RES=$(echo ${1} | netcat -i 1 localhost 50556); }

result_equals() {
    [[ ${RES} == ${1} ]] || { echo "ERROR: ${RES} not equal to ${1}" ; }
    echo -n '.'
}

start_coffee_server() {
    bash coffee_server.bash &
    sleep 1
}

remove_user_db() { rm users.db >/dev/null ; }

remove_brewed_db() { rm brewed.db >/dev/null ; }

is_not_in_user_db() {
    grep -q "${1}" users.db
    [[ $? != 0 ]] || { echo "ERROR: ${1} is still in users.db"; }
}

is_in_user_db() {
    grep -q "${1}" users.db
    [[ $? == 0 ]] || { echo "ERROR: ${1} is not in users.db"; }
}

coffee_brewed_for() {
    grep -q "${1}" brewed.db &> /dev/null
    [[ $? == 0 ]] || { echo "ERROR: nothing brewed for ${1}"; }
}

no_coffee_brewed_for() {
    grep -q "${1}" brewed.db &> /dev/null
    [[ $? != 0 ]] || { echo "ERROR: coffee still waiting for ${1}"; }
}    

tests