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

use App\Configuration\SystemConfiguration;
use KimaiPlugin\KnustBundle\Enum\Accent;

/**
 * Reads the theme options an admin set under System > Settings > Knust.
 */
final class ThemeSettings
{
    public const KEY_ACCENT = 'knust.accent';

    public function __construct(private readonly SystemConfiguration $configuration)
    {
    }

    public function accent(): Accent
    {
        $value = $this->configuration->find(self::KEY_ACCENT);

        if (!\is_string($value)) {
            return Accent::DEFAULT;
        }

        return Accent::tryFrom($value) ?? Accent::DEFAULT;
    }
}
