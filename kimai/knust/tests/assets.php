<?php

/*
 * PublicAssets without Kimai: copies Resources/public into public/bundles/knust/ when a
 * file there is missing or not the plugin's (update, downgrade), and leaves current copies alone.
 * Run: php kimai/knust/tests/assets.php
 */

require __DIR__ . '/../Service/PublicAssets.php';

use KimaiPlugin\KnustBundle\Service\PublicAssets;

$fails = 0;
function expect(string $name, mixed $expected, mixed $actual): void
{
    global $fails;
    $ok = $expected === $actual;
    $fails += $ok ? 0 : 1;
    echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' expected ' . json_encode($expected) . ' got ' . json_encode($actual)) . "\n";
}

// A Kimai project dir like a fresh container: public/bundles/ without knust/.
$base = getenv('TMPDIR') ?: sys_get_temp_dir();
$project = $base . '/knust-assets-' . getmypid();
$source = $project . '/plugin/Resources/public';
mkdir($source . '/css', 0777, true);
mkdir($source . '/fonts', 0777, true);
mkdir($project . '/public/bundles', 0777, true);
file_put_contents($source . '/css/knust.css', 'a{}');
file_put_contents($source . '/fonts/x.woff2', 'font');
$target = $project . '/public/bundles/knust';

$assets = new PublicAssets($project, $source);
expect('missing: copied', true, $assets->ensure(['css/knust.css']));
expect('missing: stylesheet there', 'a{}', @file_get_contents($target . '/css/knust.css'));
expect('missing: fonts copied too', 'font', @file_get_contents($target . '/fonts/x.woff2'));
expect('current: nothing copied', false, $assets->ensure(['css/knust.css']));

// Plugin update: the source is newer than the copy.
file_put_contents($source . '/css/knust.css', 'b{}');
touch($source . '/css/knust.css', time() + 60);
expect('older copy: copied', true, $assets->ensure(['css/knust.css']));
expect('older copy: new content', 'b{}', file_get_contents($target . '/css/knust.css'));
expect('older copy: then current', false, $assets->ensure(['css/knust.css']));

// Downgrade: the plugin's file is older than the copy.
file_put_contents($source . '/css/knust.css', 'c{}');
touch($source . '/css/knust.css', time() - 3600);
expect('downgrade: copied', true, $assets->ensure(['css/knust.css']));
expect('downgrade: old content', 'c{}', file_get_contents($target . '/css/knust.css'));

exec('rm -rf ' . escapeshellarg($project));

echo $fails === 0 ? "All checks passed\n" : "$fails failed\n";
exit($fails === 0 ? 0 : 1);
