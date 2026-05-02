<?php

$result = preg_match('/[a-zA-Z]+/', $input);
$replaced = preg_replace('/\d+/', 'X', $input);
$parts = preg_split('/\s+/', $input);
