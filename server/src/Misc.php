<?
class Misc {
    const TIMEOUT = 15;

    /*
     * Generates a random text containing letters (upper and lower case) and numbers.
     */
    public static function generateAlphanumericString($length) {
        $s = '';
        for ($i = 0; $i < $length; $i++) {
            switch (rand(1, 3)) {
                case 1: $s .= chr(rand(65, 90)); break;
                case 2: $s .= chr(rand(97, 122)); break;
                case 3: $s .= chr(rand(48, 57));
            }
        }
        return $s;
    }

    /*
     * Returns a string to be used in update queries.
     * e.g.: "col1 = val1, col2 = val2"
     */
    public static function arrayToUpdateQuery($a) {
        $query = '';
        foreach ($a as $key => $val) {
            if ($query) {
                $query .= ', ';
            }
            $query .= $key . ' = ' . $val;
        }
        return $query;
    }

    /*
     * Returns a string to be used in insert queries.
     * e.g.: "(col1, col2) VALUES (val1, val2)"
     */
    public static function arrayToInsertQuery($a) {
        $col = '';
        $values = '';
        foreach ($a as $key => $val) {
            if ($col) {
                $col .= ', ';
                $values .= ', ';
            }
            $col .= $key;
            $values .= $val;
        }
        return "($col) VALUES ($values)";
    }

    // Distance between two points.
    public static function distance($x1, $y1, $x2, $y2) {
        return sqrt(pow($x1 - $x2, 2) + pow($y1 - $y2, 2));
    }
}