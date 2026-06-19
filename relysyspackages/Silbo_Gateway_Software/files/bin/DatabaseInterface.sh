#!/bin/sh

#
# Release - 1.01
#

#
# Create New table
#
CreateTable()
{

    if [ ! -s "$DBColumnsCfgFile" ]
    then
        echo "invalid configuration file '$DBColumnsCfgFile'"
        return 1
    fi
    
    TempDir="/tmp/"
    currentDate=$(date +"%g%m%d_%H%M%S")
    TempCfgFile=$(mktemp "$TempDir""$currentDate""_"XXXXXX)
    
    # remove comments from config file
    sed '/^[[:blank:]]*#/d;s/#.*//' "$DBColumnsCfgFile" > "$TempCfgFile"
    
    # Read DBPath, DBName, & TableName from config file 
    CfgDatabasePath=$(sed -n -e 's/^\s*DatabasePath\s*=\s*//p' "$TempCfgFile")
    CfgDatabaseName=$(sed -n -e 's/^\s*DatabaseName\s*=\s*//p' "$TempCfgFile")
    CfgTableName=$(sed -n -e 's/^\s*TableName\s*=\s*//p' "$TempCfgFile")
    
    # Delete above read configuration from file
    sed -i -e '/DatabasePath/d;/DatabaseName/d;/TableName/d' "$TempCfgFile" > /dev/null 2>&1
    
    # replace all equal signs to whitespaces
    sed -i -e 's/[[:blank:]]*=[[:blank:]]*/ /g' "$TempCfgFile" > /dev/null 2>&1
    
    # join all lines to form query
    ConcatenatedPairs=$(awk -F'\n' '{if(NR == 1) {printf $0} else {printf ","$0}}' "$TempCfgFile")
    
    DatabasePath="${ArgDatabasePath:-$CfgDatabasePath}"
    DatabaseName="${ArgDatabaseName:-$CfgDatabaseName}"
    TableName="${ArgTableName:-$CfgTableName}"
    
    DatabasePath=$(echo "$DatabasePath" | sed 's/\/$//')
    Database="${DatabasePath}/${DatabaseName}"
    
    # Create Table
    DBCreateQuery="create table if not exists $TableName ($ConcatenatedPairs);"
    CreateTableMsg=$(sqlite3 "$Database" "$DBCreateQuery" 2>&1)
    CreateTableRetVal=$?
    if [ "$CreateTableRetVal" != 0 ]
    then
        rm -f "$TempCfgFile"
        echo "Failed to create '$TableName' Err-Msg: $CreateTableMsg"
        return 1
    fi

    rm -f "$TempCfgFile"
    echo "created table '$TableName' successfully"
    return 0
}

#
# Delete existing table
#
Deletetable()
{
    # Read DBPath, DBName, & TableName from config file 
    if [ -s "$DBColumnsCfgFile" ]
    then
        CfgDatabasePath=$(sed -n -e 's/^\s*DatabasePath\s*=\s*//p' "$DBColumnsCfgFile")
        CfgDatabaseName=$(sed -n -e 's/^\s*DatabaseName\s*=\s*//p' "$DBColumnsCfgFile")
        CfgTableName=$(sed -n -e 's/^\s*TableName\s*=\s*//p' "$DBColumnsCfgFile")
    fi
    
    DatabasePath="${ArgDatabasePath:-$CfgDatabasePath}"
    DatabaseName="${ArgDatabaseName:-$CfgDatabaseName}"
    TableName="${ArgTableName:-$CfgTableName}"
    
    DatabasePath=$(echo "$DatabasePath" | sed 's/\/$//')
    Database="${DatabasePath}/${DatabaseName}"
    
    # delete Table
    DBDeleteQuery="DROP TABLE ${TableName}"
    DeleteTableMsg=$(sqlite3 "$Database" "$DBDeleteQuery" 2>&1)
    DeleteTableRetVal=$?
    if [ "$DeleteTableRetVal" != 0 ]
    then
        echo "Failed to delete table '$TableName', Err-Msg: $DeleteTableMsg"
        return 1
    fi

    echo "deleted table '$TableName' successfully"
    return 0

}

#
# clear/delete records from given table
#
Cleartable()
{
    # Read DBPath, DBName, & TableName from config file 
    if [ -s "$DBColumnsCfgFile" ]
    then
        CfgDatabasePath=$(sed -n -e 's/^\s*DatabasePath\s*=\s*//p' "$DBColumnsCfgFile")
        CfgDatabaseName=$(sed -n -e 's/^\s*DatabaseName\s*=\s*//p' "$DBColumnsCfgFile")
        CfgTableName=$(sed -n -e 's/^\s*TableName\s*=\s*//p' "$DBColumnsCfgFile")
    fi
    
    DatabasePath="${ArgDatabasePath:-$CfgDatabasePath}"
    DatabaseName="${ArgDatabaseName:-$CfgDatabaseName}"
    TableName="${ArgTableName:-$CfgTableName}"
    
    DatabasePath=$(echo "$DatabasePath" | sed 's/\/$//')
    Database="${DatabasePath}/${DatabaseName}"
    
    # delete Table
    DBClearQuery="delete from ${TableName}"
    ClearTableMsg=$(sqlite3 "$Database" "$DBClearQuery" 2>&1)
    ClearTableRetVal=$?
    if [ "$ClearTableRetVal" != 0 ]
    then
        echo "Failed to delete records from table '$TableName', Err-Msg: $ClearTableMsg"
        return 1
    fi

    echo "deleted records from table '$TableName' successfully"
    return 0

}

#
# Delete database
#
DeleteDatabase()
{
    [ "x$ArgDatabaseName" = "x" ] && echo "invalid database name '$ArgDatabaseName'" && return 1
   
    if [ ! -f "$ArgDatabaseName" ]
    then
        echo "the given database '$ArgDatabaseName' does not exists"
        return 0
    fi
    
    # delete database
    RMOutput=$(rm "$ArgDatabaseName" 2>&1)
    RMRetVal=$?
    if [ "$RMRetVal" != 0 ]
    then
        echo "Failed to delete database '$ArgDatabaseName', Err-Msg: $RMOutput"
        return 1
    fi

    echo "deleted database '$ArgDatabaseName' successfully"
    return 0

}


ParseArguments ()
{
    while [ "$1" != "" ]
    do
        case $1 in
            --command )
                if [ "$#" -gt 1 ]
                then
                    Command=$2
                    shift
                fi
                ;;
                
            --config )
                if [ "$#" -gt 1 ]
                then
                    DBColumnsCfgFile=$2
                    shift
                fi
                ;;
                
            --databasepath )
                if [ "$#" -gt 1 ]
                then
                    ArgDatabasePath=$2
                    shift
                fi
                ;;
                
            --database )
                if [ "$#" -gt 1 ]
                then
                    ArgDatabaseName=$2
                    shift
                fi
                ;;
                
            --table)
                if [ "$#" -gt 1 ]
                then
                    ArgTableName=$2
                    shift
                fi
                ;;
                
            * )
                echo "invalid arguments"
                exit 1
                ;;
        esac
        shift
    done
}

#
# Validate arguments
#
if [ $# -eq 0 ]
then
    echo "invalid arguments"
    exit 1
fi

ParseArguments "$@"

case "$Command" in
    'create_table')
        CreateTable
        RetVal=$?
        exit $RetVal
        ;;

    'delete_table')
        Deletetable
        RetVal=$?
        exit $RetVal
        ;;
    
    'clear_table')
        Cleartable
        RetVal=$?
        exit $RetVal
        ;;

    'delete_database')
        DeleteDatabase
        RetVal=$?
        exit $RetVal
        ;;
        
    *)
        echo "unknown command"
        exit 1
        ;;
esac
