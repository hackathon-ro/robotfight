<html>
<body>
<table border=1 cellpadding=5>
    <?
    class Misc {
        public static function distance($x1, $y1, $x2, $y2) {
            return sqrt(pow($x1 - $x2, 2) + pow($y1 - $y2, 2));
        }
    }

    $x1 = 2;
    $y1 = 1;
    $x2 = 3;
    $y2 = 3;

    ?><tr style="background: grey"><td></td><?
    for ($j = 0; $j <= 359; $j+=10) {
        ?><td><?=$j?></td><?
    }
    ?></tr><?

    for ($i = 0; $i <= 1; $i+=0.1) {
        ?><tr><td><?=$i?></td><?
        for ($j = 0; $j <= 359; $j+=10) {
            $maxDistanceError = 1;
            $distance = Misc::distance($x1, $y1, $x2, $y2);
            $finalDistance = $distance + $maxDistanceError * ($i - 0.5);
            $x = $x1 + cos(deg2rad($j)) * $finalDistance;
            $y = $y1 + sin(deg2rad($j)) * $finalDistance;

            // Damage taken depends on distance from target.
            $maxDamage = 50;
            $maxDistance = 1;
            $dmg = max(0, $maxDamage * ($maxDistance - Misc::distance($x, $y, $x2, $y2)));
            $hp = max(0, 100 - $dmg);

            $x = round($x, 2);
            $y = round($y, 2);
            ?><td><?=$x?>, <?=$y?></td><?
        }
        ?></tr><?
    }
    ?>
</table>
</body>
</html>