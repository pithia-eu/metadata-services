#!/bin/bash

file_removed() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was removed" >> /home/ubuntu/ontology_log
}

file_modified() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was modified" >> /home/ubuntu/ontology_log
}

file_created() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was created" >> /home/ubuntu/ontology_log
}


update_file() {
    xmllint --xpath "/*/*/*/node()" $1$2 > /home/ubuntu/ontology_temp.txt
    python3 /home/ubuntu/ontology.py $2
    TIMESTAMP=`date`
    FILENAME=$(echo $2 | cut -d'.' -f 1)
    echo "[$TIMESTAMP]: File tree updated: /var/www/pithia.eu/html/ontology/2.2/$FILENAME" >> /home/ubuntu/ontology_log
}

delete_file() {
    FILENAME=$(echo $1 | cut -d'.' -f 1)
    rm -r /var/www/pithia.eu/html/ontology/2.2/$FILENAME
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: File tree deleted: /var/www/pithia.eu/html/ontology/2.2/$FILENAME" >> /home/ubuntu/ontology_log
}


inotifywait -q -m -r -e modify,delete,create /home/metadata/ontology/2.2 | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        MODIFY*)
            file_modified "$DIRECTORY" "$FILE"
	    delete_file "$FILE"
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