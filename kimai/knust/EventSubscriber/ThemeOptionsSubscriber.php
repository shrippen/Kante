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

use KevinPapst\TablerBundle\Helper\ContextHelper;
use KimaiPlugin\KnustBundle\Service\ThemeSettings;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\KernelEvent;
use Symfony\Component\HttpKernel\KernelEvents;

/**
 * Sets the Tabler options that end up as attributes on <html>:
 *   data-bs-theme-radius="0"         square corners, like the design system
 *   data-bs-theme-primary="<accent>" picked up by knust.css
 * and the logo (shrippen mark, "KIMAI" wordmark) for sidebar and login.
 * Runs after Kimai's own ThemeOptionsSubscriber (priority 100), which sets dark mode.
 */
final class ThemeOptionsSubscriber implements EventSubscriberInterface
{
    private const PRIORITY = 90;
    private const RADIUS = 0.0;
    private const LOGO = 'bundles/knust/img/knust-logo.svg';

    public function __construct(
        private readonly ContextHelper $helper,
        private readonly ThemeSettings $settings,
    ) {
    }

    public static function getSubscribedEvents(): array
    {
        return [
            KernelEvents::CONTROLLER => ['setOptions', self::PRIORITY],
        ];
    }

    public function setOptions(KernelEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $this->helper->setThemeRadius(self::RADIUS);
        $this->helper->setThemePrimary($this->settings->accent()->tablerName());

        // Fallback logo: Kimai prefers theme.branding.company / .logo when an admin set one
        $this->helper->setLogoUrl(self::LOGO);
    }
}
