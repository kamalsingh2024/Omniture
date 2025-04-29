rem This batch file builds the Omniture s_code.js ready for use.

rem Minify Removes whitespace from the JavaScript http://www.crockford.com/javascript/jsmin.html
set minify=bin\jsmin.exe

rem Minify the top part of the file, which contains the bits we edit.
rem We don't touch Omniture's obfuscated bit, which is in the bottom part.
%minify% < src\s_code_src_top.js > src\s_code_src_top_min.js 

rem Write current date to src\date.txt
date /T >src\date.txt
bin\sed.exe -e "s/^/\/\/ /" src\date.txt >src\date_output.txt

rem Concatenate the top and bottom parts together and we're done.
type src\date_output.txt src\s_code_src_top_min.js src\s_code_src_bottom.js > s_code.js

rem Delete the intermediate minified top file and date file
del src\s_code_src_top_min.js src\date.txt src\date_output.txt

rem Then we build an HTML version of the s_code.js file with the comments
type src\html\index_top.html src\s_code_src_top.js src\s_code_src_bottom.js src\html\index_bottom.html > index.html

rem Now create a dev version by switching report suites
bin\sed.exe -e  "s/telstrabpbigpondprd/telstrabpbigponddev/" s_code.js >s_code_dev.js

rem If this is Simon Rumble's machine, copy the HTML version to Dropbox
IF EXIST "C:\Users\d380861\Dropbox\Public\s_code" COPY index.html "C:\Users\d380861\Dropbox\Public\s_code"

