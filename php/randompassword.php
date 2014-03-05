#!/usr/bin/php
<?php
require "randomWordPassword.php";

function printHelp()
{
    global $argv;
    print("usage:\n\t{$argv[0]} [-h] <number of words>\n");
}

$words = 3;
$cnt = count($argv);

if ($cnt == 2 || $cnt == 3) {
    switch($argv[1]) {
        case "-h":
        case "--help":
            printHelp();
            exit(0);
            break;
        default:
            if (!is_numeric($argv[1])) {
                print_help();
                exit(1);
            }
            break;
    }
    $words = $argv[1];
}

if ($cnt == 3 && is_numeric($argv[2])) {
    $length = $argv[2];
} else {
    $length = 32;
}

print randomWordPassword($words, $length, true) . "\n";

