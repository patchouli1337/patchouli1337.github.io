#!/bin/bash
i=1
ii=1
books100="books-100.csv"
booksbbc="books-bbc.csv"
cp "$books100" /tmp/allbooks.csv
cat "$booksbbc" >> /tmp/allbooks.csv
cp "$books100" /tmp/books-100.csv
cp "$booksbbc" /tmp/books-bbc.csv

echo -n '' > booklist.csv


function getnumber {
  check=$(echo $1 | tr '[A-Z]' '[a-z]')
  number100=$(cat "$books100" | tr '[A-Z]' '[a-z]' | sed -n "/$check/{=}")
  numberbbc=$(cat "$booksbbc" | tr '[A-Z]' '[a-z]' | sed -n "/$check/{=}")
  let count=number100+numberbbc
  echo "$count"
}

cat /tmp/allbooks.csv | cut -d';' -f1 | sort | uniq -d -i | while read book; do
  number=$(getnumber "$book")
  echo "$number;$book" >> /tmp/sortbooks.csv
done

cat /tmp/sortbooks.csv | sort -g | cut -d';' -f2 | while read book; do
  string=$(cat "$books100" | grep "$book")
  author=$(echo $string | cut -d';' -f2)
  name=$(echo $string | cut -d';' -f1)
  authorru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$author&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  nameru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$name&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  if [[ $authorru ]]; then
    echo -n "$authorru;$author;" >> booklist.csv
  else
    echo -n ";$author;" >> booklist.csv
  fi
  if [[ $nameru ]]; then
    echo -n "$nameru;" >> booklist.csv
  else
    echo -n ";" >> booklist.csv
  fi
  echo -en "$name\n" >> booklist.csv
  
  let ii++
  echo "Processing: $name"
  grep -v -i "$name" /tmp/books-100.csv > /tmp/books-100-temp.csv && mv -f /tmp/books-100-temp.csv /tmp/books-100.csv
  grep -v -i "$name" /tmp/books-bbc.csv > /tmp/books-bbc-temp.csv && mv -f /tmp/books-bbc-temp.csv /tmp/books-bbc.csv
done
cat /tmp/books-100.csv | while read book; do
  bbc=$(sed -n "$i"p /tmp/books-bbc.csv)
  author100=$(echo "$book" | cut -d';' -f2)
  authorbbc=$(echo "$bbc" | cut -d';' -f2)
  name100=$(echo "$book" | cut -d';' -f1)
  namebbc=$(echo "$bbc" | cut -d';' -f1)
  author100ru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$author100&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  authorbbcru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$authorbbc&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  name100ru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$name100&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  namebbcru=$(wget --quiet -O - "http://en.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=$namebbc&lllang=ru&format=xml" | xmlstarlet sel -t -v //api/query/pages/page/langlinks/ll[1])
  
  if [[ $author100ru ]]; then
    echo -n "$author100ru;$author100;" >> booklist.csv
  else
    echo -n ";$author100;" >> booklist.csv
  fi
  if [[ $nameru ]]; then
    echo -n "$name100ru;" >> booklist.csv
  else
    echo -n ";" >> booklist.csv
  fi
  echo -en "$name100\n" >> booklist.csv
  let ii++
  echo "Processing: $name100"
  
  if [[ $authorbbcru ]]; then
    echo -n "$authorbbcru;$authorbbc;" >> booklist.csv
  else
    echo -n ";$authorbbc;" >> booklist.csv
  fi
  if [[ $namebbcru ]]; then
    echo -n "$namebbcru;" >> booklist.csv
  else
    echo -n ";" >> booklist.csv
  fi
  echo -en "$namebbc\n" >> booklist.csv
  let ii++
  echo "Processing: $namebbc"
  let i++
done

echo "$(cat booklist.csv | wc -l) books"

rm /tmp/allbooks.csv /tmp/sortbooks.csv /tmp/books-100.csv /tmp/books-bbc.csv
