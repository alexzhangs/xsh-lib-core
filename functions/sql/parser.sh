#? Description:
#?   Parse SQL expression and export the parsed into variables.
#?
#? Usage:
#?   @parser SQL
#?
#? Return:
#?   0: succeed
#?   255: error
#?
#? Export:
#?   Q_SELECTED_FIELDS
#?   Q_TABLE
#?   Q_WHERE
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   @parser select f1,f2 from A where f1 = x
#?
function parser () {
    local clause

    Q_SELECTED_FIELDS=()
    Q_TABLE=
    Q_WHERE=()

    while [[ $# -gt 0 ]]; do
        case $(x-string-lower "$1") in
            'select')
                clause='SELECT'
                ;;
            'from')
                clause="FROM"
                ;;
            'where')
                clause="WHERE"
                ;;
            *)
                case $clause in
                    'SELECT')
                        # parse the field list into array
                        IFS=',' read -r -a Q_SELECTED_FIELDS <<< "$1"
                        ;;
                    'FROM')
                        Q_TABLE=$1
                        ;;
                    'WHERE')
                        x-array-append Q_WHERE "$1"
                        ;;
                    *)
                        return 255
                        ;;
                esac
                ;;
        esac
        shift
    done

    if [[ -n ${Q_WHERE[@]} ]]; then
        xsh-sql-where-parser "${Q_WHERE[@]}"
    fi

    if [[ -z ${Q_SELECTED_FIELDS[@]} || -z $Q_TABLE ]]; then
        return 255
    else
        export Q_SELECTED_FIELDS Q_TABLE Q_WHERE
    fi
}
