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

namespace KimaiPlugin\KnustBundle\EventSubscriber;

use App\Event\ThemeEvent;
use Symfony\Component\Asset\Packages;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

/**
 * Adds the theme stylesheet after Kimai's app.css, on every page incl. login.
 * The file lives in public/bundles/knust/ (bin/console kimai:bundle:knust:install).
 */
final class StylesheetSubscriber implements EventSubscriberInterface
{
    private const STYLESHEET = 'bundles/knust/css/knust.css';
    private const SOURCE = __DIR__ . '/../Resources/public/css/knust.css';

    public function __construct(private readonly Packages $packages)
    {
    }

    public static function getSubscribedEvents(): array
    {
        return [
            ThemeEvent::STYLESHEET => ['addStylesheet', 100],
        ];
    }

    public function addStylesheet(ThemeEvent $event): void
    {
        // Cache buster follows the plugin's copy, so browsers reload after every update
        $url = $this->packages->getUrl(self::STYLESHEET) . '?v=' . (string) @filemtime(self::SOURCE);

        $event->addContent(\sprintf('<link rel="stylesheet" href="%s">', htmlspecialchars($url, \ENT_QUOTES)));
    }
}
