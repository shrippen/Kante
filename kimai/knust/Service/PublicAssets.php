<?php

/*
 * This file is part of the KnustBundle plugin for Kimai.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Copyright (C) 2026 Arian
 */

namespace KimaiPlugin\KnustBundle\Service;

use Symfony\Component\DependencyInjection\Attribute\Autowire;

/**
 * Keeps public/bundles/knust/ in step with Resources/public/ (CSS, fonts, logo).
 *
 * Kimai copies plugin assets only by console (kimai:bundle:knust:install,
 * assets:install), and in the Docker image public/ is no volume: a new container
 * (every Kimai update) starts without them, the stylesheets answer 404 and Kimai
 * shows up unthemed (live instance after the update to 2.71, 27.10.2026). So the
 * theme copies them again itself, on every cache warmup (AssetsWarmer):
 *
 *   container start / kimai:reload ──► ensure(files) ──► missing or not of the plugin's file time?
 *                                                          │ yes: copy all of Resources/public
 *                                                          └ no:  nothing
 *
 * The start script warms the cache as root: the copies then go to the owner of
 * public/bundles (www-data), so a later kimai:reload as www-data can replace them.
 *
 * Plain PHP, no Symfony Filesystem: tests/assets.php runs without Kimai.
 */
class PublicAssets
{
    private const TARGET = '/public/bundles/knust';
    private const SOURCE = __DIR__ . '/../Resources/public';
    private const DIR_MODE = 0775;

    public function __construct(
        #[Autowire('%kernel.project_dir%')] private readonly string $projectDir,
        private readonly string $source = self::SOURCE,
    ) {
    }

    /**
     * @param list<string> $files paths below Resources/public, e.g. "css/knust.css"
     * @return bool true when it copied
     * @throws \RuntimeException when the copy fails (public/bundles not writable)
     */
    public function ensure(array $files): bool
    {
        $target = $this->projectDir . self::TARGET;
        foreach ($files as $file) {
            if (!$this->isCurrent($target . '/' . $file, $this->source . '/' . $file)) {
                $this->copyDir($this->source, $target);

                return true;
            }
        }

        return false;
    }

    // The copy carries the plugin file's time (copyDir()); any other time is an update, a downgrade or a copy by hand.
    private function isCurrent(string $copy, string $original): bool
    {
        $copied = @filemtime($copy);

        return $copied !== false && $copied === @filemtime($original);
    }

    private function copyDir(string $from, string $to): void
    {
        if (!is_dir($to) && !@mkdir($to, self::DIR_MODE, true) && !is_dir($to)) {
            throw new \RuntimeException('Knust: cannot create ' . $to);
        }
        $this->handOver($to);

        foreach (scandir($from) ?: [] as $name) {
            if ($name === '.' || $name === '..') {
                continue;
            }
            $path = $from . '/' . $name;
            if (is_dir($path)) {
                $this->copyDir($path, $to . '/' . $name);
                continue;
            }
            if (!@copy($path, $to . '/' . $name)) {
                throw new \RuntimeException('Knust: cannot copy ' . $name . ' to ' . $to);
            }
            // Like cp -p: the time marks the copy as current (isCurrent()), also for a file dated ahead.
            @touch($to . '/' . $name, (int) filemtime($path));
            $this->handOver($to . '/' . $name);
        }
    }

    // As root: give the copy the owner of public/bundles. Anyone else keeps their own files.
    private function handOver(string $path): void
    {
        if (!\function_exists('posix_geteuid') || posix_geteuid() !== 0) {
            return;
        }

        $bundles = \dirname($this->projectDir . self::TARGET);
        @chown($path, (int) fileowner($bundles));
        @chgrp($path, (int) filegroup($bundles));
    }
}
