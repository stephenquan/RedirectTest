#!/bin/bash -xe

portal_url=https://www.arcgis.com

cache_dir=/tmp/cache
rest_json=${cache_dir}/rest.json
token_json=${cache_dir}/token.json
user_json=${cache_dir}/user.json
content_json=${cache_dir}/content.json
item_json=${cache_dir}/item.json
additem_json=${cache_dir}/additem.json
createfolder_json=${cache_dir}/createfolder.json
delete_json=${cache_dir}/delete.json
update_json=${cache_dir}/update.json
files_txt=${cache_dir}/files.txt
folders_txt=${cache_dir}/folders.txt

make_cache_dir() {
    if [ ! -d ${cache_dir} ]; then
        mkdir ${cache_dir}
    fi
}

clean_cache_dir() {
    args=()
    args+=(${cache_dir} )
    args+=(-maxdepth 2 )
    args+=(-mmin +60 )
    args+=(-type f )
    args+=(-delete)
    find ${args[@]}

    args=()
    args+=(${cache_dir} )
    args+=(-maxdepth 2 )
    args+=(-mmin +1 )
    args+=(-type f )
    args+=(-name '\*.txt')
    args+=(-delete)
    find ${args[@]}
}

get_rest_json() {
    make_cache_dir
    if [ -f ${rest_json} ]; then
        return
    fi
    url=${portal_url}/sharing/rest/info
    args=()
    args+=(-s)
    args+=(-G)
    args+=(--data-urlencode f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${rest_json}
}

get_value() {
    json_file=$1
    json_key=$2
    cat ${json_file} | sed -e 's/^\s*"'${json_key}'\"\s*:\s*"\(.*\)",*$/\1/;t;d' | head -1
}

get_token_json() {
    if [ -f ${token_json} ]; then
        return
    fi
    get_rest_json
    url=$(get_value ${rest_json} tokenServicesUrl)
    read -p "Enter username: " username
    read -s -p "Enter password: " password
    echo password is ${password}
    args=()
    args+=(-s)
    args+=(-X POST)
    args+=(-H "Content Type: application/x-www-form-urlencoded")
    args+=(--data-urlencode username=${username})
    args+=(--data-urlencode password=${password})
    args+=(--data-urlencode referer=${portal_url})
    args+=(--data-urlencode f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${token_json}
}

get_token() {
    get_token_json
    token=$(get_value ${token_json} token)
}

get_user_json() {
    if [ -f ${user_json} ]; then
        return
    fi
    get_token
    url=${portal_url}/sharing/rest/community/self
    args=()
    args+=(-s)
    args+=(-G)
    args+=(--data-urlencode token=${token})
    args+=(--data-urlencode f=pjson )
    args+=(${url})
    curl "${args[@]}" > ${user_json}
}

get_username() {
    get_user_json
    username=$(get_value ${user_json} username)
}

set_content_json() {
    content_json=${cache_dir}/content-${folder_id}.json
}

set_files_txt() {
    files_txt=${cache_dir}/files-${folder_id}.txt
}

get_content_json() {
    set_content_json
    get_username
    get_token
    url=${portal_url}/sharing/rest/content/users/${username}/${folder_id}
    args=()
    args+=(-s)
    args+=(-G)
    args+=(--data-urlencode token=${token})
    args+=(--data-urlencode f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${content_json}
}

add_item() {
    item_title=$1
    item_file=@$1
    get_token
    get_username
    url=${portal_url}/sharing/rest/content/users/${username}/${folder_id}/addItem
    args=()
    # args+=(-s)
    args+=(--verbose)
    args+=(-X POST)
    args+=(-H "Content Type: application/x-www-form-urlencoded")
    args+=(-F file=${item_file})
    args+=(-F title=${item_title})
    args+=(-F type="Code Sample")
    args+=(-F tags="qml,snippet")
    args+=(-F token=${token})
    args+=(-F f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${additem_json}
    cat ${additem_json}
    item_id=$(get_value ${additem_json} id)
    if [ -f ${content_json} ]; then
        rm ${content_json}
    fi
    if [ -f ${files_txt} ]; then
        rm ${files_txt}
    fi
}

update_item() {
    item_title=$1
    item_file=@$1
    get_token
    get_username
    url=${portal_url}/sharing/rest/content/users/${username}/${folder_id}/items/${item_id}/update
    args=()
    args+=(--verbose)
    args+=(-X POST)
    args+=(-H "Content Type: application/x-www-form-urlencoded")
    # args+=(-H "Content Type: multipart/form-data")
    args+=(-F file=${item_file})
    # args+=(-F title=${item_title})
    args+=(-F token=${token})
    args+=(-F f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${update_json}
    cat ${update_json}
}

get_files_txt() {
    set_files_txt
    if [ -f "${files_txt}" ]; then
        return
    fi
    get_content_json
    cat ${content_json} | grep -e '"\(id\|title\|folders\)"' | sed -n -e "1,/folders/p" > ${files_txt}
}

get_folders_txt() {
    if [ -f "${folders_txt}" ]; then
        return
    fi
    get_content_json
    cat ${content_json} | grep -e '"\(id\|title\|folders\)"' | sed -n -e "/folders/,\$p" > ${folders_txt}
}

get_item_id() {
    get_files_txt
    title=$1
    item_id=$(grep -B1 -e '"title": "'${title}'"' ${files_txt} | get_value "" id)
}

get_folder_id() {
    get_folders_txt
    title=$1
    folder_id=$(grep -B1 -e '"title": "'${title}'"' ${folders_txt} | get_value "" id)
}

delete_item() {
    item_id=$1
    get_username
    get_token
    url=${portal_url}/sharing/rest/content/users/${username}/items/${item_id}/delete
    args=()
    args+=(-s)
    args+=(-X POST)
    args+=(--data-urlencode token=${token})
    args+=(--data-urlencode f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${delete_json}
    cat ${delete_json}
}

create_folder() {
    folder_title=$1
    get_token
    get_username
    url=${portal_url}/sharing/rest/content/users/${username}/createFolder
    args=()
    agrs+=(-s)
    args+=(-X POST)
    args+=(-H "Content Type: application/x-www-form-urlencoded")
    args+=(--data-urlencode title=${folder_title})
    args+=(--data-urlencode token=${token})
    args+=(--data-urlencode f=pjson)
    args+=(${url})
    curl "${args[@]}" > ${createfolder_json}
    cat ${createfolder_json}
    folder_id=$(get_value ${createfolder_json} id)
}

file_name=$1
folder_name=$2

if [ "${file_name}" == "" ]; then
    cat <<EOF
Syntax: UpdatePortalItem.sh file_name folder_name
EOF
    exit 1
fi

make_cache_dir
clean_cache_dir

if [ "${folder_name}" != "" ]; then
  get_folders_txt
  get_folder_id CertCheck
  if [ "${folder_id}" == "" ]; then
    create_folder CertCheck
  fi
fi

get_files_txt
get_item_id "${file_name}"
if [ "${item_id}" == "" ]; then
  add_item "${file_name}"
else
  update_item "${file_name}"
fi

url=${portal_url}/sharing/rest/content/items/${item_id}/data?token=${token}
args=()
args+=(-L)
args+=(${url})

echo curl ${args[@]}
curl ${args[@]}
