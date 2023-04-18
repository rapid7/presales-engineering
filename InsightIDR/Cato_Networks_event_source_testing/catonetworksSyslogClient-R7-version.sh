#! /bin/bash
#!/usr/local/bin/bash 
#      ^ version for v5 in OS X via brew install bash
# Downloads and extracts log files from S3 bucket stored by Cato Networks
# This is a modified version of a Cato Networks script to download the files, and prepares them for forwarding to Rapid7's InsightIDR collector
# This script will output the contents of the text file inside the zip file directly to the screen
#
# THIS IS A PROOF OF CONCEPT CODE THAT IS NOT VALIDATED FOR PRODUCTION USAGE.
# It will need further modifications to increase resiliency and reliability

# References:
#   https://stackoverflow.com/questions/32095741/how-to-download-a-page-with-wget-but-ignore-404-error-messages-if-the-page-does
#   https://superuser.com/questions/457559/loop-over-a-range-of-numbers-to-download-with-wget


BUCKET_URL_PREFIX="https://s3-eu-west-1.amazonaws.com/REDACTED-S3-BUCKET-NAME"
API_KEY="REDACTED"
STORAGE_FILE=./storage${API_KEY:0:5}
MAX_NUM_FAILURES=5

# maybe use Bash 4.0 syntax to provide a list to curl of files to download, or generate a text file that has all the possible URLs
# store the URLs that have been successfully downloaded, but won't work on OS X
#last=3829 # now managed by setup_counter() function

COUNTER_FILE="$HOME/.cato-networks-S3-counter-${API_KEY:0:5}.dat"     # persistent text file that stores the last successful downloaded file

# InsightIDR clock problems, make sure log lines are recent?

#wget "https://s3-eu-west-1.amazonaws.com/REDACTED-S3-BUCKET-NAME/REDACTED-GUID/CATO00000000000000000020.zip"
#unzip -P "REDACTED_FILENAME" CATO00000000000000000020.zip

# don't use ""s in bash 5 for {} variables, it breaks it.
#wget --no-clobber --content-on-error https://s3-eu-west-1.amazonaws.com/REDACTED-S3-BUCKET-NAME/REDACTED-GUID/CATO0000000000000000000{1..9}.zip


log() {
    echo -e $(date +"[%m-%d %H:%M:%S]") "$1" | fold -w120 -s
}

setup_counter() {
 
    # if we don't have a file, start at zero
    if [ ! -f "$COUNTER_FILE" ] ; then
        last=0
    # otherwise read the value from the file
    else
        last=$(cat "$COUNTER_FILE")
    fi

    # increment the value
    last=$(( last + 1))
    # and save it for next time
    echo "${last}" > "$COUNTER_FILE"
}

tryDownloadFile(){
    fileName="$1"
    extraFileName="$2"
    #STATUSCODE=$(curl --silent --write-out "%{http_code}" -O "${BUCKET_URL_PREFIX}/${API_KEY}/${fileName}")

    STATUSCODE=$(curl --silent \
                    --write-out "%{http_code}" \
                    --connect-timeout 5 \
                    --max-time 10 \
                    --retry 5 \
                    --retry-delay 0 \
                    --retry-max-time 40 \
                    -O "${BUCKET_URL_PREFIX}/${API_KEY}/${fileName}" )

    if [ "$STATUSCODE" -eq 200 ]; then
        unzip -P "$pass" -p "${fileName}"
        rm "${fileName}" > /dev/null
        ((last++))
        echo "$last 1" > ${STORAGE_FILE}
        log "successfully downloaded ${fileName}"
        count=0
    elif [ "$STATUSCODE" -eq 403 ]; then
        rm "${fileName}" > /dev/null
        if [ -n "$extraFileName" ]; then
            tryDownloadFile "${extraFileName}"
        else
            exit 0;
        fi
    elif (( "$count" > "${MAX_NUM_FAILURES}" )); then       # can't I just pass a different arg to curl to have automatic retries?
        log "too many failures for ${last}; skipping this file"
        last=$((last+1))
        echo "$last 1" > ${STORAGE_FILE}
    else
        ((count++))
        echo "$last $count" > ${STORAGE_FILE}
    fi
}

# initialize the counter to the previous one
setup_counter

# initialize the number of attempts counter at 0
count=0

# Cato sets the password to to zip file to be the first 10 characters of the API key
pass=${API_KEY::10}

if [ -f "${STORAGE_FILE}" ]; then
    IFS=' ' read -r tempLast tempCount < ${STORAGE_FILE}
    if [ "$tempLast" -gt "$last" ]; then
        last="$tempLast"
        count="$tempCount"
    fi
fi

# loop through all possible filenames and download all of them.
while true; do
    lastWithLeading=$(printf "%020d" "${last}")
    fileName=CATO${lastWithLeading}
    tryDownloadFile "${fileName}.zip"
done
