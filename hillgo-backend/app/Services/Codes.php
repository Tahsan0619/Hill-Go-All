<?php

namespace App\Services;

class Codes
{
    /** Short unique public codes, e.g. HG-88021, HG-RD-9921, CG-99420. */
    public static function make(string $prefix): string
    {
        return $prefix . '-' . strtoupper(substr(base_convert((string) (microtime(true) * 10000), 10, 36), -6)) . random_int(0, 9);
    }
}
