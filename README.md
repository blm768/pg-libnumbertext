# `pg-libnumbertext`

This PosgreSQL extension provides bindings to [`libnumbertext`](https://github.com/Numbertext/libnumbertext), which allows users to convert numeric values to their corresponding words in various languages.

## Project status

This project is in an early alpha state, but the basic functionality seems to be operational.

## Building

Download the source for the appropriate [release](https://github.com/Numbertext/libnumbertext/releases) of `libnumbertext` (in `tar.xz` format) and place it in the root of the repository. Then run `make` and `make install`.

## Usage

Start by loading the extension:

```sql
CREATE EXTENSION IF NOT EXISTS pg_libnumbertext;
```

The extension API consists of a single function, `numbertext` which takes two text arguments: the digits of the number to be converted and a (typically two-character) language code. It returns the converted text.

```sql
CREATE EXTENSION IF NOT EXISTS pg_libnumbertext;
SELECT numbertext('1', 'en');
 numbertext 
------------
 one
(1 row)

SELECT numbertext('3', 'ja');
 numbertext 
------------
 三
(1 row)
```

### Running tests

The `docker` directory contains code to build a Docker image that will automatically run the regression tests. To use it, execute `./run-tests.sh` (in the repository's root directory).

## Caveats

At least for now, the database server **must** be configured to operate using the UTF-8 character encoding (which is the typical default for PostreSQL installations).
