#!/bin/bash
customDie() {
    echo
    echo
    echo "ERROR:"
    echo "$1"
    echo
    echo
    exit 1
}

# pep8-3 says:
# pep8 has been renamed to pycodestyle (GitHub issue #466)
# Use of the pep8 tool will be removed in a future release.
# Please install and use `pycodestyle` instead.
PCS_CMD=pycodestyle-3
if [ ! -f "`command -v pycodestyle-3`" ]; then
    pycodestyle_version=`python3 -m pycodestyle --version`
    if [ $? -ne 0 ]; then
        customDie "pycodestyle-3 is missing ('python3 -m pycodestyle --version' didn't work either). You must first install the python3-pycodestyle package."
    else
        PCS_CMD="python3 -m pycodestyle"
    fi
fi

tmp_path=style-check-output.txt
if [ -f "$tmp_path" ]; then
    rm "$tmp_path" || customDie "rm \"$tmp_path\" failed."
fi
echo > "$tmp_path"
# for name in example-cli.py setup.py testing.pyw pypicolcd/lcdframebuffer.py pypicolcd/command_line.py pypicolcd/stats.py pypicolcd/__init__.py
for name in `ls *.py` `ls gcodesynth/*.py`
do
    echo "* checking '$name'..."
    $PCS_CMD $name  >> "$tmp_path"
done

if [ -f "`command -v outputinspector`" ]; then
    outputinspector "$tmp_path"
    if [ $? -ne 0 ]; then
        echo "* \"$tmp_path\" <<END:"
        cat "$tmp_path"
        echo "END"
        echo "(outputinspector failed)"
    fi
    # rm "$tmp_path"
    # sleep 3
else
    cat "$tmp_path"
    cat <<END

Instead of cat, this script can use outputinspector if you install it
  (If you double-click on any error, outputinspector will tell Geany or
  Kate to navigate to the line and column in your program):

  <https://github.com/poikilos/outputinspector>

END
rm "$tmp_path"
fi

