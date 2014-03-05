<?php

$_random_password_filename = "dict";
$f = file($_random_password_filename);
$count = count($f);

/** Grab a random word from a dictionary file */
function randomWord($capitalize = false)
{
    global $count, $f;
    $random = rand(0, $count-1);

    if ($capitalize) {
        $cc = "ucfirst";
    } else {
        $cc = "lcfirst";
    }

    return $cc(trim($f[$random]));
}

/** Generate a random password of $length words */
function randomWordPassword($length, $maxlength = 32, $capitalize = false)
{
    $length = rand(2, $length);

    while (1) {
        $password = "";

        for ($x = 0; $x < $length; ++$x) {
            $password .= randomWord($capitalize);
        }

        // try again if it's too long
        if (strlen($password) > $maxlength) {
            continue;
        }

        return $password;
    }
}

/** Print a random password of $length words followed by a new line */
function printRandomWordPassword($length)
{
    print(randomWordPassword($length) . "\n");
}

