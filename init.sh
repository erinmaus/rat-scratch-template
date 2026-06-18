function escape_name() {
    echo $1 | sed 's/[]\/$*.^[]/\\&/g'
}

function update_placeholder() {
    spaces_pattern=$'[ \t]*'
    filename=$1
	old_value=$(escape_name $2)
    new_value=$(escape_name $3)

    sed -i .bak "s/$old_value/$new_value/g" $filename
    rm $filename.bak
}

update_placeholder "package.json" rat-scratch-template $1
update_placeholder ".rsmeta" rat-scratch-template $1
update_placeholder "README.md" rat-scratch-template $1
mv rat-scratch-template $1
