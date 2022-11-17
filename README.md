# Hocon

Hocon data parser for c.

## Overview
This project is a Hocon data parser for c. We use flex && bison to scan and parse files or strings, and stored the parsed results in cJSON Object. 

## Features
- [x] Json parse.
- [x] Path expression parse.
- [x] Value merging.
- [x] Comment.
- [ ] Reference.
- [ ] Value joint.
- [ ] Multiline string.
- [ ] Whitespace.

## Building
- Get the code from github
```shell
git clone https://github.com/nanomq/hocon.git
```
- Build project
```shell
cd hocon && mkdir build
cd build && cmake ..
make
```

## Usage
- Parse from file
```shell
    char *hocon_file_path = "your/hconf/file/path";
    cJSON *ret = hocon_parse_file(hocon_file_path);

```
- parse from string
```shell
    char str[] = "abc=1";
    cJSON *ret = hocon_parse_str(str, strlen(str));

```

Then you can use cJSON interface to read data from cJSON object.


