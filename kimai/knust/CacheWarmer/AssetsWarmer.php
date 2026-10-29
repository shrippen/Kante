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

namespace KimaiPlugin\KnustBundle\CacheWarmer;

use KimaiPlugin\KnustBundle\Service\PublicAssets;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpKernel\CacheWarmer\CacheWarmerInterface;

/**
 * Copies the theme's assets back into public/bundles/knust/ on every cache warmup:
 * the Docker image's start script runs kimai:reload, so a new container (Kimai
 * update) gets them before the first page, and so does a plugin update
 * (kimai:reload). No cost on page loads.
 */
final class AssetsWarmer implements CacheWarmerInterface
{
    /** Below Resources/public: the stylesheets (StylesheetSubscriber) and the logo (ThemeOptionsSubscriber) */
    private const CHECKED = ['css/knust-palette.css', 'css/knust.css', 'img/knust-logo.svg'];

    public function __construct(
        private readonly PublicAssets $assets,
        private readonly LoggerInterface $logger,
    ) {
    }

    // Not optional: cache:warmup --no-optional-warmers must not skip it.
    public function isOptional(): bool
    {
        return false;
    }

    public function warmUp(string $cacheDir, ?string $buildDir = null): array
    {
        try {
            $this->assets->ensure(self::CHECKED);
        } catch (\RuntimeException $e) {
            // A failed copy must not stop kimai:reload; Kimai then shows up unthemed.
            $this->logger->warning($e->getMessage() . ' (fix: bin/console kimai:bundle:knust:install)');
        }

        return [];
    }
}
