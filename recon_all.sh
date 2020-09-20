#!/usr/bin/env bash

set -e


work_dir=$(dirname $0)
source "$work_dir/paths.sh"
source "$work_dir/functions.sh"

TARGETS_DIR=$1

if [ ! -d "$TARGETS_DIR" ]; then
    echo "Directory '$TARGETS_DIR' does not exist"
    cli_help
fi

echo "Targets directory: $TARGETS_DIR"
echo "Targets found:"
echo "$(ls $TARGETS_DIR)"

cd $TARGETS_DIR

# Loop over targets
for target in *; do 
    [[ -d $target ]] || continue

    target_dir="$TARGETS_DIR/$target"
    domains_file="$target_dir/domains.txt"
    while IFS= read -r domain; do
        [[ ! -z $domain ]] || continue
        enumerate_subdomains $domain $target_dir
    done < "$domains_file"

    probe_subdomains $target_dir
    cloud_bucket_enum $target_dir
    nuclei_scan $target_dir
    take_screenshots $target_dir
    crawl_sites $target_dir
    crawl_js $target_dir
done

echo ""
echo "Done."
