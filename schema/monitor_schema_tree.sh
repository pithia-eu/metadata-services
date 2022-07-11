#!/bin/bash

file_removed() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was removed" >> schema_log
}

file_modified() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was modified" >> schema_log
}

file_created() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was created" >> schema_log
}


update_file() {
    rm /var/www/pithia.eu/html/schema/$2
    cp $1$2 /var/www/pithia.eu/html/schema/$2
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: File updated: /var/www/pithia.eu/html/schema/$2" >> schema_log
}

delete_file() {
    rm /var/www/pithia.eu/html/schema/$1
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: File deleted: /var/www/pithia.eu/html/schema/$1" >> schema_log
}


inotifywait -q -m -r -e modify,delete,create $1 @$1/.git | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        MODIFY*)
            file_modified "$DIRECTORY" "$FILE"
            update_file "$DIRECTORY" "$FILE"
            ;;
        CREATE*)
            file_created "$DIRECTORY" "$FILE"
            ;;
        DELETE*)
            file_removed "$DIRECTORY" "$FILE"
            delete_file "$FILE"
            ;;
    esac
done
