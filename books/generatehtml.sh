#!/bin/bash
i=1
cat booklist.csv | while read value; do
  echo -e "<tr>\n  <td>$i</td>"
  authorru=$(echo $value | cut -d';' -f1)
  if [[ $authorru ]]; then
    echo -e "  <td><a href='http://ru.wikipedia.org/wiki/$(echo $authorru | sed -e 's/ /_/g')'>$authorru</a></td>"
  else
    echo -e "  <td>$(echo $value | cut -d';' -f2)</td>"
  fi
  name=$(echo $value | cut -d';' -f3)
  if [[ $name ]]; then
    echo -e "  <td><a href='http://flibusta.net/booksearch?ask=$(echo $name | sed -e 's/ /%20/g')'>$name</a></td>"
  else
    echo -e "  <td></td>"
  fi
  echo -e "  <td>$(echo $value | cut -d';' -f4)</td>"
  echo -e "</tr>\n"
  let i++
done
