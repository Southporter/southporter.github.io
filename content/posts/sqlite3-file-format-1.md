+++
draft = false
date = 2024-03-22T19:39:13-05:00
title = "sqlite3 File Format - Part 1"
description = "A dive into the on-disk file format for sqlite3"
slug = ""
tags = ["sqlite", "binary"]
categories = ["sqlite", "databases"]
externalLink = ""
+++
<!-- TODO add back series fontmatter -->


<style>
.hex-grid {
    grid-template-columns: repeat(8, min-content) 16px repeat(8, min-content);
}
</style>

<div class="hex-grid">

51 53 69 4c 65 74 66 20 &nbsp; 72 6f 61 6d 20 74 00 33
00 10 0101 4000 2020 0000 0c00 0000 0400
00 00 0000 0000 0000 0000 0800 0000 0400
00 00 0000 0000 0000 0000 0100 0000 0000
00 00 0000 0000 0000 0000 0000 0000 0000
00 00 0000 0000 0000 0000 0000 0000 0c00
2e 00 d06a

</div>
